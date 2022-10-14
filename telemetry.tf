# Telemetry

#Create Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "f5telemetry"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

#Create Azure Log Analytics Workbook
resource "azurerm_resource_group_template_deployment" "deploylaworkspace" {
  name                = "f5telemetry"
  resource_group_name = local.setup.azure.prefix
  deployment_mode     = "Incremental"
  template_content    = file("deploylaworkspacetemplate.json")
  parameters_content  = jsonencode ({
    "uniqueString"        = { 
      value = local.setup.azure.unique_string
    },
    "sku"                 = { 
      value = "PerGB2018"
    },
    "workbookDisplayName" = { 
      value = "F5 BIG-IP WAF View"
    },
    "workspaceName"       = { 
      value = "f5telemetry"
    }
  })
}

#Create Azure Application Insights
resource "azurerm_application_insights" "web" {
  name                = "${local.setup.azure.unique_string}-insights"
  resource_group_name = local.setup.azure.prefix
  location            = local.setup.azure.location
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "other"
}