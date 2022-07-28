# Use of AS3 patch with Terraform
# CRUD "PATCH" is a supported method to be used with AS3.
# When AS3 is used with Terraform the use of "PATCH" is prohibited!!!

terraform {
  required_version = "~> 1.1.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.94.0"
    }
    bigip = {
      source = "F5Networks/bigip"
      version = "1.13.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.tmp.subscription_id
  client_id       = local.tmp.client_id
  client_secret   = local.tmp.client_secret
  tenant_id       = local.tmp.tenant_id
}

locals {
  setup = yamldecode(file(var.setupfile))
  tmp   = yamldecode(file(var.tmpfile))
  hostname = data.azurerm_public_ip.bigip0_mgmt_pip.ip_address
}

provider "bigip" {
  address  = local.hostname
  username = local.setup.bigip.user_name
  password = local.setup.bigip.user_password
}

data azurerm_network_interface "bigip0_management" {
  name                = "${local.setup.azure.prefix}-bigip0-mgmt-nic"
  resource_group_name = local.setup.azure.prefix
}

data azurerm_network_interface "bigip1_management" {
  name                = "${local.setup.azure.prefix}-bigip1-mgmt-nic"
  resource_group_name = local.setup.azure.prefix
}

data azurerm_public_ip "bigip0_mgmt_pip" {
  name                = "${local.setup.azure.prefix}-bigip0-mgmt-pip"
  resource_group_name = "${local.setup.azure.prefix}"
}

data azurerm_public_ip "bigip1_mgmt_pip" {
  name                = "${local.setup.azure.prefix}-bigip1-mgmt-pip"
  resource_group_name = "${local.setup.azure.prefix}"
}


locals {
    use_case_3_json = templatefile("${path.module}/use_case_3.tpl", {
      vip-5        = local.setup.vips.vip-5
  })
}

# BIGIP AS3 Builder
resource "bigip_as3" "as3_use_case_3" {
  as3_json = local.use_case_3_json
}
