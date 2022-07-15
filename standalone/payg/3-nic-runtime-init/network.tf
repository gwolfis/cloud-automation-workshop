#Create the VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.cidr]
}

#Create the Subnets
resource "azurerm_subnet" "management" {
  name                 = "${var.prefix}-mgmt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_management
}

resource "azurerm_subnet" "external" {
  name                 = "${var.prefix}-ext"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_external
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-int"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_internal
}