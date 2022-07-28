#Create the VNET BIGIP environment
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.setup.azure.prefix}-vnet"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  address_space       = [local.setup.network.cidr]
}

#Create the Subnets
resource "azurerm_subnet" "management" {
  name                 = "${local.setup.azure.prefix}-mgmt"
  resource_group_name  = local.setup.azure.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.setup.network.subnet_management]
}

resource "azurerm_subnet" "external" {
  name                 = "${local.setup.azure.prefix}-ext"
  resource_group_name  = local.setup.azure.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.setup.network.subnet_external]
}

resource "azurerm_subnet" "internal" {
  name                 = "${local.setup.azure.prefix}-int"
  resource_group_name  = local.setup.azure.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.setup.network.subnet_internal]
}

resource "azurerm_subnet" "webserver" {
  name                 = "${local.setup.azure.prefix}-web"
  resource_group_name  = local.setup.azure.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.setup.network.subnet_webserver]
}

# Azure Route Table to Support CFE
resource "azurerm_route_table" "cfe_udr" {
  name                          = "${local.setup.azure.prefix}-rt-cfe-udr"
  resource_group_name           = local.setup.azure.prefix
  location                      = local.setup.azure.location
  disable_bgp_route_propagation = false

  route {
    name                   = "internal_route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.bigip0_internal.private_ip_address
  }

  tags = {
    f5_cloud_failover_label = "${local.setup.azure.prefix}-failover-label"
    f5_self_ips             = "${azurerm_network_interface.bigip0_internal.private_ip_address}, ${azurerm_network_interface.bigip1_internal.private_ip_address}"
  }
}