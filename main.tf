terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  tags                = local.common_tags
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  tags                = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Hitesh Naga Pavan"
  }
}
