resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

variable "name"     { type = string }
variable "location" { type = string }
variable "tags"     { type = map(string) }

output "name"     { value = azurerm_resource_group.this.name }
output "location" { value = azurerm_resource_group.this.location }
output "id"       { value = azurerm_resource_group.this.id }
