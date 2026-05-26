resource "azurerm_storage_account" "this" {
  name                     = "st${var.project}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  min_tls_version          = "TLS1_2"

  # Security settings
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = true
  default_to_oauth_authentication  = true

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Storage container for app data
resource "azurerm_storage_container" "app_data" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "project"             { type = string }
variable "tags"                { type = map(string) }

output "id"   { value = azurerm_storage_account.this.id }
output "name" { value = azurerm_storage_account.this.name }
output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}
