variable "client_id" {
  description = "The Client ID for the Service Principal"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Southeast Asia"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_service_plan_tier" {
  description = "App Service Plan tier (Basic, Standard, Premium)"
  type        = string
}

variable "app_service_plan_size" {
  description = "App Service Plan size (B1, B2, B3, S1, S2, S3, P1, P2, P3)"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for subnets"
  type        = map(list(string))
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "docker_image" {
  description = "Docker image URI for the app service"
  type        = string
  default     = ""
}

variable "enable_ci_cd" {
  description = "Enable CI/CD pipeline"
  type        = bool
  default     = true
}

variable "repository_url" {
  description = "Git repository URL for CI/CD"
  type        = string
  default     = ""
}

variable "repository_branch" {
  description = "Git repository branch"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
