# Telemetry

#Create Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "f5telemetry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
  depends_on = [ azurerm_resource_group.rg
  ]
}

#Create Azure Log Analytics Workbook
resource "azurerm_template_deployment" "deploylaworkspace" {
  name                = "f5telemetry"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("deploylaworkspacetemplate.json")
  parameters = {
    "uniqueString"        = var.unique_string
    "sku"                 = "PerGB2018"
    "workbookDisplayName" = "F5 BIG-IP WAF View"
    "workspaceName"       = "f5telemetry"
  }
  depends_on = [ azurerm_resource_group.rg
  ]
}

#Create Azure Application Insights
resource "azurerm_application_insights" "web" {
  name                = "${var.unique_string}-insights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "other"
}