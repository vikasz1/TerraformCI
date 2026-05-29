# Production Environment Configuration

environment = "prod"

resource_group_name = "terraform-app-rg-prod"
location            = "Southeast Asia"

# App Service Plan - Standard tier for production with higher capacity
app_service_plan_tier = "S"
app_service_plan_size = "2"
app_service_name      = "myapp"

# Virtual Network Configuration
vnet_address_space = ["10.1.0.0/16"]

subnet_address_prefixes = {
  app_subnet = ["10.1.1.0/24"]
  db_subnet  = ["10.1.2.0/24"]
}

# Docker Image (optional - leave empty for built-in stack)
docker_image = ""

# CI/CD Configuration
enable_ci_cd      = true
repository_url    = "https://github.com/your-org/your-repo.git"
repository_branch = "main"

# Tags
tags = {
  Project     = "TerraformApp"
  Environment = "Production"
  CostCenter  = "PROD-001"
  Owner       = "DevOps Team"
}
