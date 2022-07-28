terraform {
  required_version = "~> 1.1.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.94.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">2.1.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">2.1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    bigip = {
      source  = "F5Networks/bigip"
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
}

# Create a random id
resource "random_id" "id" {
  byte_length = 2
}

resource "azurerm_storage_account" "cfe_storage" {
  name                     = "${random_id.id.hex}cfestorage"
  resource_group_name      = local.setup.azure.prefix
  location                 = local.setup.azure.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    name                    = "${local.setup.azure.prefix}-cfe-storage"
    environment             = local.setup.azure.environment
    f5_cloud_failover_label = "${local.setup.azure.prefix}-failover-label"
  }
}

# resource "azurerm_ssh_public_key" "f5_key" {
#   name                = format("%s-pubkey-%s", local.setup.azure.prefix, random_id.id.hex)
#   resource_group_name = local.setup.azure.prefix
#   location            = local.setup.azure.location
#   public_key          = file("~/.ssh/id_rsa.pub")
# }

#Create Azure Managed User Identity and Role Definition
resource "azurerm_user_assigned_identity" "user_identity" {
  name                = "${local.setup.azure.prefix}-ident"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
}

data "azurerm_subscription" "rg" {}

resource "azurerm_role_assignment" "bigip0_contributor" {
  scope              = data.azurerm_subscription.rg.id
  role_definition_id = "${data.azurerm_subscription.rg.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = lookup(azurerm_linux_virtual_machine.bigip0.identity[0], "principal_id")
}

resource "azurerm_role_assignment" "bigip1_contributor" {
  scope              = data.azurerm_subscription.rg.id
  role_definition_id = "${data.azurerm_subscription.rg.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = lookup(azurerm_linux_virtual_machine.bigip1.identity[0], "principal_id")
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}