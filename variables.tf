variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "landing-zone"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefix = string
  }))
  default = {
    app = {
      address_prefix = "10.0.1.0/24"
    }
    data = {
      address_prefix = "10.0.2.0/24"
    }
    mgmt = {
      address_prefix = "10.0.3.0/24"
    }
  }
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}
