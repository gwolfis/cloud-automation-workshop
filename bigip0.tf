# BIG-IP Failover via-lb

# Public IP BIGIP0
resource "azurerm_public_ip" "bigip0_mgmt_pip" {
  name                = "${local.setup.azure.prefix}-bigip0-mgmt-pip"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bigip0_ext_pip" {
  name                = "${local.setup.azure.prefix}-bigip0-ext-pip"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bigip0_ext_vpip_1" {
  name                = "${local.setup.azure.prefix}-bigip-ext-vpip-1"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bigip0_ext_vpip_2" {
  name                = "${local.setup.azure.prefix}-bigip-ext-vpip-2"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bigip0_ext_vpip_3" {
  name                = "${local.setup.azure.prefix}-bigip-ext-vpip-3"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Network Interfaces BIGIP0
resource "azurerm_network_interface" "bigip0_management" {
  name                = "${local.setup.azure.prefix}-bigip0-mgmt-nic"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip0-mgmt-ip"
    subnet_id                     = azurerm_subnet.management.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bigip0_mgmt_pip.id
  }
}

resource "azurerm_network_interface" "bigip0_external" {
  name                          = "${local.setup.azure.prefix}-bigip0-ext-nic"
  resource_group_name           = local.setup.azure.prefix
  location                      = local.setup.azure.location
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip0-ext-ip"
    subnet_id                     = azurerm_subnet.external.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bigip0_ext_pip.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-0"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-0
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_0.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-1"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-1
    public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_1.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-2"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-2
    public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_2.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-3"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-3
    public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_3.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-4"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-4
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_4.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-5"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-5
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_5.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-6"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-6
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_6.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-7"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-7
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_7.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-8"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-8
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_8.id
  }

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-vpip-9"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.vips.vip-9
    //public_ip_address_id          = azurerm_public_ip.bigip0_ext_vpip_9.id
  }

  tags = {
    f5_cloud_failover_label   = "${local.setup.azure.prefix}-failover-label"
    f5_cloud_failover_nic_map = "external"
  }
}

resource "azurerm_network_interface" "bigip0_internal" {
  name                          = "${local.setup.azure.prefix}-bigip0-int-nic"
  resource_group_name           = local.setup.azure.prefix
  location                      = local.setup.azure.location
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "${local.setup.azure.prefix}-bigip0-int-ip"
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
resource "azurerm_network_interface_security_group_association" "bigip0_mgmtnsg" {
  network_interface_id      = azurerm_network_interface.bigip0_management.id
  network_security_group_id = azurerm_network_security_group.mgmtnsg.id
}

resource "azurerm_network_interface_security_group_association" "bigip0_extnsg" {
  network_interface_id      = azurerm_network_interface.bigip0_external.id
  network_security_group_id = azurerm_network_security_group.extnsg.id
}

resource "azurerm_network_interface_security_group_association" "bigip0_intnsg" {
  network_interface_id      = azurerm_network_interface.bigip0_internal.id
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

# Onboard Template BIGIP0
locals {
  bigip_onboard0 = templatefile("${path.module}/onboard.tpl", {
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
    host_name               = "${local.setup.azure.prefix}-bigip0"
    host_name_0             = "${local.setup.azure.prefix}-bigip0"
    host_name_1             = "${local.setup.azure.prefix}-bigip1"
    remote_host_int         = "/Common/failoverGroup/members/0"
    self_ip_external        = azurerm_network_interface.bigip0_external.private_ip_address
    self_ip_internal        = azurerm_network_interface.bigip0_internal.private_ip_address
    management_gateway      = local.setup.network.management_gateway
    external_gateway        = local.setup.network.external_gateway
    f5_cloud_failover_label = "${local.setup.azure.prefix}-failover-label"
    unique_string           = local.setup.azure.unique_string
    workspace_id            = azurerm_log_analytics_workspace.law.workspace_id
    primary_key             = azurerm_log_analytics_workspace.law.primary_shared_key
  })
}

# BIGIP0 VM
resource "azurerm_linux_virtual_machine" "bigip0" {
  name                            = "${local.setup.azure.prefix}-bigip0"
  resource_group_name             = local.setup.azure.prefix
  location                        = local.setup.azure.location
  size                            = local.setup.bigip.instance_type
  zone                            = 1
  disable_password_authentication = false
  admin_username                  = local.setup.bigip.user_name
  admin_password                  = local.setup.bigip.user_password
  network_interface_ids           = [azurerm_network_interface.bigip0_management.id, azurerm_network_interface.bigip0_external.id, azurerm_network_interface.bigip0_internal.id]
  custom_data                     = base64encode(local.bigip_onboard0)

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

