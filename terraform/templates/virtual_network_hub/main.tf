# Notes:
# "this" is used when it is the only resource of this type included in the template
# therefore no unique identifier is necessary.

locals {
  scope = lower(var.scope)
  safe_scope = replace(local.scope, "-", "")
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-vnet-hub-${var.location}-${local.scope}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.location}-${local.scope}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.address_space
  dns_servers         = null
  tags                = var.tags

}