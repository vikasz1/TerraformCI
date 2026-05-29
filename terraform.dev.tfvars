# Development Environment Configuration

environment = "dev"

resource_group_name = "terraform-app-rg-dev"
location            = "Southeast Asia"

# App Service Plan - Standard tier for development
app_service_plan_tier = "S"
app_service_plan_size = "1"
app_service_name      = "myappvikasbaheri"

# Virtual Network Configuration
vnet_address_space = ["10.0.0.0/16"]

subnet_address_prefixes = {
  app_subnet = ["10.0.1.0/24"]
  db_subnet  = ["10.0.2.0/24"]
}

# Docker Image (optional - leave empty for built-in stack)
docker_image             = "vikasz1/buddycodz:latest"
docker_registry_url      = "https://index.docker.io"
docker_registry_username = ""
docker_registry_password = ""

# CI/CD Configuration
enable_ci_cd      = true
repository_url    = "https://github.com/your-org/your-repo.git"
repository_branch = "develop"

# Tags
tags = {
  Project     = "TerraformApp"
  Environment = "Development"
  CostCenter  = "DEV-001"
  Owner       = "DevOps Team"
}
