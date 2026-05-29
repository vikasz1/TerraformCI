# Local values for common configuration
locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy   = "Terraform"
      Environment = var.environment
      CreatedAt   = timestamp()
    }
  )

  naming_convention = {
    resource_group_name = "${var.resource_group_name}-${var.environment}"
    storage_account     = "sa${replace(var.resource_group_name, "-", "")}${var.environment}"
    vnet_name           = "${var.resource_group_name}-vnet-${var.environment}"
    app_subnet_name     = "${var.resource_group_name}-app-subnet-${var.environment}"
    db_subnet_name      = "${var.resource_group_name}-db-subnet-${var.environment}"
    nsg_name            = "${var.resource_group_name}-app-nsg-${var.environment}"
    app_service_name    = "${var.app_service_name}-${var.environment}"
    app_service_plan    = "${var.app_service_name}-plan-${var.environment}"
    app_insights_name   = "${var.app_service_name}-insights-${var.environment}"
  }
}
