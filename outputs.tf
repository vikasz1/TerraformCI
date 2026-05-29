output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "Storage Account Name"
  value       = azurerm_storage_account.storage.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = azurerm_virtual_network.vnet.name
}

output "app_subnet_id" {
  description = "App Subnet ID"
  value       = azurerm_subnet.app_subnet.id
}

output "db_subnet_id" {
  description = "Database Subnet ID"
  value       = azurerm_subnet.db_subnet.id
}

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.app_service_plan.id
}

output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.app_service.id
}

output "app_service_name" {
  description = "App Service Name"
  value       = azurerm_linux_web_app.app_service.name
}

output "app_service_default_hostname" {
  description = "App Service Default Hostname"
  value       = azurerm_linux_web_app.app_service.default_hostname
}

output "app_service_url" {
  description = "App Service URL"
  value       = "https://${azurerm_linux_web_app.app_service.default_hostname}"
}

output "app_service_principal_id" {
  description = "App Service Managed Identity Principal ID"
  value       = azurerm_linux_web_app.app_service.identity[0].principal_id
}

output "staging_slot_name" {
  description = "Staging Slot Name"
  value       = var.enable_ci_cd ? azurerm_linux_web_app_slot.staging[0].name : null
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = azurerm_application_insights.app_insights.id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights Connection String"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}
