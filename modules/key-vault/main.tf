data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.project}-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  tags                        = var.tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
  }
}

# Grant current service principal access
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "project"             { type = string }
variable "tags"                { type = map(string) }

output "id"   { value = azurerm_key_vault.this.id }
output "name" { value = azurerm_key_vault.this.name }
output "uri"  { value = azurerm_key_vault.this.vault_uri }
