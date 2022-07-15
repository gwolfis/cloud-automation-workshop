# Applications

# Onboard script the web
locals {
  web_custom_data = <<EOF
    #cloud-config

    package_update: true
    package_upgrade: true

    runcmd:
      - apt-get update -y
      - apt-get -y install docker.io
      - docker run --name f5demo -p 80:80 -p 443:443 -d f5devcentral/f5-demo-app:latest

    final_message: "The system is finally up, after $UPTIME seconds"
    EOF
}

# Create Application
resource "azurerm_virtual_machine_scale_set" "appvmss" {
  name                = "${var.prefix}-appvmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"

  sku {
    name     = "Standard_B1ls"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "web"
    admin_username       = var.user_name
    admin_password       = var.user_password
    custom_data          = base64encode(local.web_custom_data)
  }

  network_profile {
    name                      = "internal"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.intnsg.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }

  tags = {
    discovery = var.service_discovery_value
  }
}
