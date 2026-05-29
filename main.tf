terraform {
  required_version = ">= 0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.43.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use Service Principal authentication via environment variables
  # (set by azure/login GitHub Action)
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "sa${replace(var.resource_group_name, "-", "")}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet-${var.environment}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Subnets
resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.resource_group_name}-app-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes["app_subnet"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.resource_group_name}-db-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes["db_subnet"]
}

# Network Security Group for App Subnet
resource "azurerm_network_security_group" "app_nsg" {
  name                = "${var.resource_group_name}-app-nsg-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-plan-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "${var.app_service_plan_tier}${var.app_service_plan_size}"

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# App Service
resource "azurerm_linux_web_app" "app_service" {
  name                = "${var.app_service_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    minimum_tls_version = "1.2"
    http2_enabled       = true

    dynamic "application_stack" {
      for_each = var.docker_image != "" ? [1] : []
      content {
        docker_image_name   = var.docker_image
        docker_registry_url = "https://index.docker.io"
      }
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_ENABLE_CI"                     = var.enable_ci_cd ? "true" : "false"
    "ENVIRONMENT"                          = var.environment
  }

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Virtual Network Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.app_service.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

# CI/CD - GitHub Actions configuration
resource "azurerm_linux_web_app_slot" "staging" {
  count           = var.enable_ci_cd ? 1 : 0
  name            = "staging"
  app_service_id  = azurerm_linux_web_app.app_service.id
  
  site_config {
    minimum_tls_version = "1.2"
    http2_enabled       = true
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "ENVIRONMENT"                          = "${var.environment}-staging"
  }

  https_only = true

  tags = merge(
    var.tags,
    {
      Environment = "${var.environment}-staging"
      ManagedBy   = "Terraform"
    }
  )
}

# Application Insights for monitoring
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_service_name}-insights-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Connect App Service to Application Insights
resource "azurerm_monitor_diagnostic_setting" "app_service_diagnostics" {
  name                       = "${var.app_service_name}-diagnostics-${var.environment}"
  target_resource_id         = azurerm_linux_web_app.app_service.id
  log_analytics_workspace_id = null

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}