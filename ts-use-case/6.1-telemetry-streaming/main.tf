# AS3 - sharing of objects
# Application in a Tenant making use of /Common objects
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

data azurerm_public_ip "bigip0_ext_vpip_2" {
  name                = "${local.setup.azure.prefix}-bigip-ext-vpip-2"
  resource_group_name = "${local.setup.azure.prefix}"
}

locals {
    ts_use_case_json = templatefile("${path.module}/ts_use_case.tpl", {
      vip-2        = local.setup.vips.vip-2
      poolmember-2 = local.setup.web.poolmember-2
  })
}

# BIGIP AS3 Builder
resource "bigip_as3" "as3_ts_use_case" {
  as3_json = local.ts_use_case_json
}
