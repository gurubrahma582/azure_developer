# ============================================================================
# Azure Resource Group Terraform Configuration
# ============================================================================
# This Terraform configuration creates an Azure Resource Group with an
# environment-specific naming convention for deployments such as dev and qa.
#
# Prerequisites:
#   - Terraform >= 1.0
#   - Azure CLI installed and authenticated (az login)
#   - Appropriate Azure subscription permissions

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

variable "environment" {
  description = "Deployment environment name (for example: dev, qa, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod", "test"], lower(var.environment))
    error_message = "Environment must be one of: dev, qa, prod, or test."
  }
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Explicit Azure resource group name to create or manage."
  type        = string
  default     = "dev-rg-warehouse-azure"
}

locals {
  environment_name    = lower(var.environment)
  resolved_rg_name    = var.resource_group_name != "" ? var.resource_group_name : "${local.environment_name}-rg-warehouse-azure"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resolved_rg_name
  location = var.location
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}
