# BIG-IP Failover via-lb

# Public IP BIGIP1
resource "azurerm_public_ip" "bigip1_mgmt_pip" {
  name                = "${local.setup.azure.prefix}-bigip1-mgmt-pip"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bigip1_ext_pip" {
  name                = "${local.setup.azure.prefix}-bigip1-ext-pip"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

# resource "azurerm_public_ip" "bigip1_ext_vpip" {
#   name                = "${local.setup.azure.prefix}-bigip1-ext-vpip"
#   resource_group_name = local.setup.azure.prefix
#   location            = local.setup.azure.location
#   sku                 = "Standard"
#   allocation_method   = "Static"
# }

# Network Interfaces BIGIP1
resource "azurerm_network_interface" "bigip1_management" {
  name                = "${local.setup.azure.prefix}-bigip1-mgmt-nic"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip1-mgmt-ip"
    subnet_id                     = azurerm_subnet.management.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bigip1_mgmt_pip.id
  }
}

resource "azurerm_network_interface" "bigip1_external" {
  name                          = "${local.setup.azure.prefix}-bigip1-ext-nic"
  resource_group_name           = local.setup.azure.prefix
  location                      = local.setup.azure.location
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip1-ext-ip"
    subnet_id                     = azurerm_subnet.external.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bigip1_ext_pip.id
  }

  //ip_configuration {
  //name                          = "${local.setup.azure.prefix}-bigip1-ext-vip"
  //subnet_id                     = azurerm_subnet.external.id
  //private_ip_address_allocation = "Dynamic"
  //public_ip_address_id          = azurerm_public_ip.bigip1_ext_vpip.id
  //}

  tags = {
    f5_cloud_failover_label   = "${local.setup.azure.prefix}-failover-label"
    f5_cloud_failover_nic_map = "external"
  }
}

resource "azurerm_network_interface" "bigip1_internal" {
  name                          = "${local.setup.azure.prefix}-bigip1-int-nic"
  resource_group_name           = local.setup.azure.prefix
  location                      = local.setup.azure.location
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip1-int-ip"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = {
    f5_cloud_failover_label   = "${local.setup.azure.prefix}-failover-label"
    f5_cloud_failover_nic_map = "internal"
  }
}

# Associate NSG with Network Interfaces
resource "azurerm_network_interface_security_group_association" "bigip1_mgmtnsg" {
  network_interface_id      = azurerm_network_interface.bigip1_management.id
  network_security_group_id = azurerm_network_security_group.mgmtnsg.id
}

resource "azurerm_network_interface_security_group_association" "bigip1_extnsg" {
  network_interface_id      = azurerm_network_interface.bigip1_external.id
  network_security_group_id = azurerm_network_security_group.extnsg.id
}

resource "azurerm_network_interface_security_group_association" "bigip1_intnsg" {
  network_interface_id      = azurerm_network_interface.bigip1_internal.id
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

# Onboard Template BIGIP1
locals {
  bigip_onboard1 = templatefile("${path.module}/onboard.tpl", {
    INIT_URL                = local.setup.f5_atc.INIT_URL
    DO_URL                  = local.setup.f5_atc.DO_URL
    AS3_URL                 = local.setup.f5_atc.AS3_URL
    TS_URL                  = local.setup.f5_atc.TS_URL
    CFE_URL                 = local.setup.f5_atc.CFE_URL
    FAST_URL                = local.setup.f5_atc.FAST_URL
    DO_VER                  = split("/", local.setup.f5_atc.DO_URL)[7]
    AS3_VER                 = split("/", local.setup.f5_atc.AS3_URL)[7]
    TS_VER                  = split("/", local.setup.f5_atc.TS_URL)[7]
    CFE_VER                 = split("/", local.setup.f5_atc.CFE_URL)[7]
    FAST_VER                = split("/", local.setup.f5_atc.FAST_URL)[7]
    user_name               = local.setup.bigip.user_name
    user_password           = local.setup.bigip.user_password
    host_name               = "${local.setup.azure.prefix}-bigip1"
    host_name_0             = "${local.setup.azure.prefix}-bigip0"
    host_name_1             = "${local.setup.azure.prefix}-bigip1"
    remote_host_int         = azurerm_network_interface.bigip0_internal.private_ip_address
    self_ip_external        = azurerm_network_interface.bigip1_external.private_ip_address
    self_ip_internal        = azurerm_network_interface.bigip1_internal.private_ip_address
    management_gateway      = local.setup.network.management_gateway
    external_gateway        = local.setup.network.external_gateway
    f5_cloud_failover_label = "${local.setup.azure.prefix}-failover-label"
    unique_string           = local.setup.azure.unique_string
    workspace_id            = azurerm_log_analytics_workspace.law.workspace_id
    primary_key             = azurerm_log_analytics_workspace.law.primary_shared_key
  })
}

# BIGIP1 VM
resource "azurerm_linux_virtual_machine" "bigip1" {
  name                            = "${local.setup.azure.prefix}-bigip1"
  resource_group_name             = local.setup.azure.prefix
  location                        = local.setup.azure.location
  size                            = local.setup.bigip.instance_type
  zone                            = 2
  disable_password_authentication = false
  admin_username                  = local.setup.bigip.user_name
  admin_password                  = local.setup.bigip.user_password
  network_interface_ids           = [azurerm_network_interface.bigip1_management.id, azurerm_network_interface.bigip1_external.id, azurerm_network_interface.bigip1_internal.id]
  custom_data                     = base64encode(local.bigip_onboard1)

  //admin_ssh_key {
    //username   = local.setup.bigip.user_name
    //public_key = azurerm_ssh_public_key.f5_key.public_key
  //}

  identity {
    type = "SystemAssigned"
    //identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }

  plan {
    name      = local.setup.bigip.image_name
    publisher = "f5-networks"
    product   = local.setup.bigip.product
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = local.setup.bigip.product
    sku       = local.setup.bigip.image_name
    version   = local.setup.bigip.bigip_version
  }

  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
}

