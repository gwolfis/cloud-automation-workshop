# Create two webservers

# Create Web01 NIC
resource "azurerm_network_interface" "web01-nic" {
  name                = "${local.setup.azure.prefix}-web01-nic"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.webserver.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.web.poolmember-1
    primary                       = true
  }

  tags = {
    name        = "${local.setup.azure.prefix}-web01"
    environment = local.setup.azure.environment
  }
  depends_on = [ azurerm_network_security_group.intnsg ]
}

# Create Web02 NIC
resource "azurerm_network_interface" "web02-nic" {
  name                = "${local.setup.azure.prefix}-web02-nic"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.webserver.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.setup.web.poolmember-2
    primary                       = true
  }

  tags = {
    name        = "${local.setup.azure.prefix}-web02"
    environment = local.setup.azure.environment
  }
  depends_on = [ azurerm_network_security_group.intnsg  ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "web01-nsg-int" {
  network_interface_id      = azurerm_network_interface.web01-nic.id
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

resource "azurerm_network_interface_security_group_association" "web02-nsg-int" {
  network_interface_id      = azurerm_network_interface.web02-nic.id
  network_security_group_id = azurerm_network_security_group.intnsg.id
}

# Onboard script the web01
locals {
  web_custom_data = <<EOF
    #cloud-config

    package_update: true
    package_upgrade: true

    runcmd:
      - apt-get update -y
      - apt-get -y install docker.io
      - sleep 30
      - docker run --name f5demo --restart always -p 80:80 -p 443:443 -d f5devcentral/f5-demo-app:latest

    final_message: "The system is finally up, after $UPTIME seconds"
EOF
}

# # Onboard script the web02
# locals {
#   web02_custom_data = <<EOF
#     #cloud-config

#     package_update: true
#     package_upgrade: true

#     runcmd:
#       - apt-get update -y
#       - apt-get -y install docker.io
#       - sleep 30
#       - docker run --name f5demo --restart always -p 80:80 -p 443:443 -d f5devcentral/f5-demo-app:latest

#     final_message: "The system is finally up, after $UPTIME seconds"
# EOF
# }

# Create VM web01
resource "azurerm_linux_virtual_machine" "web01" {
  name                            = "${local.setup.azure.prefix}-web01"
  resource_group_name             = local.setup.azure.prefix
  location                        = local.setup.azure.location
  network_interface_ids           = [azurerm_network_interface.web01-nic.id]
  size                            = "Standard_B1ms"
  admin_username                  = local.setup.bigip.user_name
  admin_password                  = local.setup.bigip.user_password
  disable_password_authentication = false
  computer_name                   = "${local.setup.azure.prefix}-web01"
  custom_data                     = base64encode(local.web_custom_data)

  os_disk {
    name                 = "web01OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    name              = "${local.setup.azure.prefix}-web01"
    environment       = local.setup.azure.environment
    service_discovery = local.setup.web.service_discovery_value
  }
}

# Create VM web02
resource "azurerm_linux_virtual_machine" "web02" {
  name                            = "${local.setup.azure.prefix}-web02"
  resource_group_name             = local.setup.azure.prefix
  location                        = local.setup.azure.location
  network_interface_ids           = [azurerm_network_interface.web02-nic.id]
  size                            = "Standard_B1ms"
  admin_username                  = local.setup.bigip.user_name
  admin_password                  = local.setup.bigip.user_password
  disable_password_authentication = false
  computer_name                   = "${local.setup.azure.prefix}-web02"
  custom_data                     = base64encode(local.web_custom_data)

  os_disk {
    name                 = "web02OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    name              = "${local.setup.azure.prefix}-web02"
    environment       = local.setup.azure.environment
    service_discovery = local.setup.web.service_discovery_value
  }
}