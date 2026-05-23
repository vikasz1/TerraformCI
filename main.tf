terraform {
  required_version = ">= 0.12"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.43.0"
    }
  }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}


resource "azurerm_resource_group" "rg" {
  name = "TerraformLearn"
  location = "Southeast Asia"
}

resource "azurerm_storage_account" "storage" {
  name = "savikas87907"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "RAGRS"
}