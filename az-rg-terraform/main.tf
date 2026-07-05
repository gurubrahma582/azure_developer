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
  default     = "East US"
}

locals {
  environment_name    = lower(var.environment)
  resource_group_name = "${local.environment_name}-rg-warehouse-azure"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}
