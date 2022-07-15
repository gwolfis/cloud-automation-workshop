# BIG-IP Standalone


# Public IP
resource "azurerm_public_ip" "mgmt_pip" {
    name                = "${var.prefix}${count.index}-mgmt-pip${count.index}"
    count               = var.default_instance_count
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

resource "azurerm_public_ip" "ext_pip" {
    name                = "${var.prefix}${count.index}-ext-pip${count.index}"
    count               = var.default_instance_count
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

resource "azurerm_public_ip" "ext_vpip" {
    name                = "${var.prefix}${count.index}-ext-vpip${count.index}"
    count               = var.default_instance_count
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Standard"
    allocation_method   = "Static"
}

# Network Interfaces
resource "azurerm_network_interface" "management" {
  name                = "${var.prefix}${count.index}-mgmt-nic${count.index}"
  count               = var.default_instance_count
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  ip_configuration {
    name                          = "${var.prefix}${count.index}-mgmt-ip${count.index}"
    subnet_id                     = azurerm_subnet.management.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.mgmt_pip.*.id,count.index)}"
  }
}

resource "azurerm_network_interface" "external" {
  name                          = "${var.prefix}${count.index}-ext-nic${count.index}"
  count                         = var.default_instance_count
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "${var.prefix}${count.index}-ext-ip${count.index}"
    subnet_id                     = azurerm_subnet.external.id
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.ext_pip.*.id,count.index)}"
  }

  ip_configuration {
    name                          = "${var.prefix}${count.index}-ext-vip${count.index}"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.ext_vpip.*.id,count.index)}"
  }
}

resource "azurerm_network_interface" "internal" {
  name                          = "${var.prefix}${count.index}-int-nic${count.index}"
  count                         = var.default_instance_count
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "${var.prefix}${count.index}-int-ip${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_network_interface_security_group_association" "mgmtnsg" {
  network_interface_id      = "${element(azurerm_network_interface.management.*.id,count.index)}"
  count                     = var.default_instance_count
  network_security_group_id = azurerm_network_security_group.mgmtnsg.id
}

resource "azurerm_network_interface_security_group_association" "extnsg" {
  network_interface_id      = "${element(azurerm_network_interface.external.*.id,count.index)}"
  count                     = var.default_instance_count
  network_security_group_id = azurerm_network_security_group.extnsg.id
}

resource "azurerm_network_interface_security_group_association" "intnsg" {
  network_interface_id      = "${element(azurerm_network_interface.internal.*.id,count.index)}"
  count                     = var.default_instance_count
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

# Onboard Template
data "template_file" "init_file" {
  count = var.default_instance_count
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
    discovery        = var.service_discovery_value
    self_ip_external = element(azurerm_network_interface.external.*.private_ip_address,count.index)
    self_ip_internal = element(azurerm_network_interface.internal.*.private_ip_address,count.index)
    ext_vip          = element(azurerm_network_interface.external[count.index].private_ip_addresses, 1)
  }
}

# BIG-IP VM
resource "azurerm_linux_virtual_machine" "bigip" {
  name                            = "${var.prefix}${count.index}"
  count                           = var.default_instance_count
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.instance_type
  disable_password_authentication = false
  admin_username                  = var.user_name
  admin_password                  = var.user_password
  network_interface_ids           = [element(azurerm_network_interface.management.*.id, count.index), element(azurerm_network_interface.external.*.id, count.index), element(azurerm_network_interface.internal.*.id, count.index)]
  custom_data                     = base64encode(data.template_file.init_file[count.index].rendered)

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

