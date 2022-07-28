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
      version = "1.14.0"
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

data azurerm_public_ip "bigip0_mgmt_pip" {
  name                = "${local.setup.azure.prefix}-bigip0-mgmt-pip"
  resource_group_name = "${local.setup.azure.prefix}"
}

resource "bigip_ltm_pool" "mypool" {
  name                = "/Common/test-pool"
  allow_nat           = "yes"
  allow_snat          = "yes"
  load_balancing_mode = "round-robin"
}

resource "bigip_ltm_policy" "import" {
  name     = "/Common/import-rule"
  strategy = "first-match"
  requires = ["client-ssl", "tcp"]
  controls = ["forwarding"]

  rule {
    name = "Rule-01"
    condition {
      ssl_extension = true
      server_name   = true
      ends_with     = true
      values = [
        "domain1.net",
        "domain2.nl"
      ]
    }
    condition {
      tcp     = true
      matches = true
      values = [
        "10.0.0.0/8",
        "20.0.0.0/8",
      ]
    }
    action {
      forward          = true
      pool             = "/Common/test-pool"
      ssl_client_hello = true
    }
  }

  rule {
    name = "lastrule-deny"
    action {
      shutdown         = true
      ssl_client_hello = true
    }
  }
}