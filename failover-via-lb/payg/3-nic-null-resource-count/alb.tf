# Azure Load Balancer

# Create Public IPs
resource "azurerm_public_ip" "alb_pip" {
  name                = "${var.prefix}-alb-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

# Create ALB
resource "azurerm_lb" "alb" {
  name                = "${var.prefix}-alb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "VIP_Pub_IP"
    public_ip_address_id = azurerm_public_ip.alb_pip.id
  }
}

# Create backend pool
resource "azurerm_lb_backend_address_pool" "bigip_backend_pool" {
  loadbalancer_id = azurerm_lb.alb.id
  name            = "BIG-IP_Backend_Pool"
  depends_on = [ azurerm_network_interface.external ]
}

# Create probe
resource "azurerm_lb_probe" "alb_probe_http" {
  name                = "http-probe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.alb.id
  protocol            = "Tcp"
  port                = 80
}

resource "azurerm_lb_probe" "alb_probe_https" {
  name                = "https-probe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.alb.id
  protocol            = "Tcp"
  port                = 443
}

# Create ALB rules
resource "azurerm_lb_rule" "alb_rule_http" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "alb-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "VIP_Pub_IP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bigip_backend_pool.id]
  probe_id                       = azurerm_lb_probe.alb_probe_http.id
}

resource "azurerm_lb_rule" "alb_rule_https" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "alb-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "VIP_Pub_IP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bigip_backend_pool.id]
  probe_id                       = azurerm_lb_probe.alb_probe_https.id
}