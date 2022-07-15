# BIG-IP Standalone


# Public IP
resource "azurerm_public_ip" "mgmt_pip" {
    name                = "${var.prefix}-mgmt-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

resource "azurerm_public_ip" "ext_pip" {
    name                = "${var.prefix}-ext-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

resource "azurerm_public_ip" "ext_vpip" {
    name                = "${var.prefix}-ext-vpip"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

# Network Interfaces
resource "azurerm_network_interface" "management" {
  name                = "${var.prefix}-mgmt-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  ip_configuration {
    name                          = "${var.prefix}-mgmt-ip"
    subnet_id                     = azurerm_subnet.management.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmt_pip.id
  }
}

resource "azurerm_network_interface" "external" {
  name                          = "${var.prefix}-ext-nic"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "${var.prefix}-ext-ip"
    subnet_id                     = azurerm_subnet.external.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ext_pip.id
  }

  ip_configuration {
    name                          = "${var.prefix}-ext-vip"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ext_vpip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                          = "${var.prefix}-int-nic"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "${var.prefix}-int-ip"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_network_interface_security_group_association" "mgmtnsg" {
  network_interface_id      = azurerm_network_interface.management.id
  network_security_group_id = azurerm_network_security_group.mgmtnsg.id
}

resource "azurerm_network_interface_security_group_association" "extnsg" {
  network_interface_id      = azurerm_network_interface.external.id
  network_security_group_id = azurerm_network_security_group.extnsg.id
}

resource "azurerm_network_interface_security_group_association" "intnsg" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

# Onboard Template
data "template_file" "init_file" {
  template = file("${path.module}/onboard.tpl")
  vars = {
    INIT_URL         = var.INIT_URL
    DO_URL           = var.DO_URL
    AS3_URL          = var.AS3_URL
    TS_URL           = var.TS_URL
    DO_VER           = split("/", var.DO_URL)[7]
    AS3_VER          = split("/", var.AS3_URL)[7]
    TS_VER           = split("/", var.TS_URL)[7]
    user_name        = var.user_name
    user_password    = var.user_password
    //discovery        = var.service_discovery_value
    self_ip_external = azurerm_network_interface.external.private_ip_address
    self_ip_internal = azurerm_network_interface.internal.private_ip_address
    //ext_vip          = "${element(azurerm_network_interface.external.private_ip_addresses, 1)}" 
  }
}

resource "bigip_as3" "app_services" {
  depends_on = [azurerm_linux_virtual_machine.bigip,data.template_file.init_file]
  as3_json   = local.as3_json
}

resource "local_file" "as3" {
    content     = local.as3_json
    filename    = "${path.module}/as3-bigip.json"
}

locals {
    as3_json = templatefile("${path.module}/as3.tpl", {
    
    resource_group_name = azurerm_resource_group.rg.name
    discovery           = var.service_discovery_value
    subscription_id     = var.subscription_id
    //ext_vip             = element(azurerm_network_interface.external.private_ip_addresses, 1)
  })
}

# BIG-IP VM
resource "azurerm_linux_virtual_machine" "bigip" {
  name                            = "${var.prefix}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.instance_type
  disable_password_authentication = false
  admin_username                  = var.user_name
  admin_password                  = var.user_password
  network_interface_ids           = [azurerm_network_interface.management.id, azurerm_network_interface.external.id, azurerm_network_interface.internal.id]
  custom_data                     = base64encode(data.template_file.init_file.rendered)

  admin_ssh_key {
    username   = var.user_name
    public_key = azurerm_ssh_public_key.f5_key.public_key
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }

  plan {
    name      = var.image_name
    publisher = "f5-networks"
    product   = var.product
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }

  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
}

