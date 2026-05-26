# ============================================================
#  Terraform Azure Landing Zone
#  Author: R. Hitesh Naga Pavan
#  Description: Full Azure environment provisioning with
#               VNet, NSG, Key Vault, Storage & Resource Groups
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  # Remote state — Azure Blob Storage
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatehitesh"
    container_name       = "tfstate"
    key                  = "landing-zone.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ── Resource Group ──────────────────────────────────────────
module "resource_group" {
  source   = "./modules/resource-group"
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# ── Networking ───────────────────────────────────────────────
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

# ── Key Vault ────────────────────────────────────────────────
module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  tags                = local.common_tags
}

# ── Storage Account ──────────────────────────────────────────
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
