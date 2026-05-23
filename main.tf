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


resource "azurerm_resource_group" "rg" {
  name     = "TerraformLearn"
  location = "Southeast Asia"
}

resource "azurerm_storage_account" "storage" {
  name                     = "savikas87907"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}