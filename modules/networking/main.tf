# ── Virtual Network ─────────────────────────────────────────
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ── Subnets ──────────────────────────────────────────────────
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.key}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}

# ── Network Security Group ───────────────────────────────────
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow HTTPS inbound
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH from management subnet only
  security_rule {
    name                       = "Allow-SSH-Mgmt"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── Associate NSG with all subnets ───────────────────────────
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = azurerm_subnet.this
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# ── Variables ────────────────────────────────────────────────
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "project"             { type = string }
variable "vnet_address_space"  { type = list(string) }
variable "subnets" {
  type = map(object({ address_prefix = string }))
}
variable "tags" { type = map(string) }

# ── Outputs ──────────────────────────────────────────────────
output "vnet_id"    { value = azurerm_virtual_network.this.id }
output "vnet_name"  { value = azurerm_virtual_network.this.name }
output "subnet_ids" { value = { for k, v in azurerm_subnet.this : k => v.id } }
output "nsg_id"     { value = azurerm_network_security_group.this.id }
