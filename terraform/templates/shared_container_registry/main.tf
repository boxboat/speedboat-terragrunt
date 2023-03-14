# # ACR name must be globally unique
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.scope}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "this" {
  name                          = substr("acr${local.safe_scope}", 0, 49)
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Premium"
  public_network_access_enabled = true
  admin_enabled                 = false
}

data "azuread_user" "admins" {
  for_each            = toset(var.registry_users)
  user_principal_name = each.value
}

locals {
  admin_users = { for user in data.azuread_user.admins : user.user_principal_name => user.object_id }
}

resource "azurerm_role_assignment" "user_acrpush" {
  for_each             = local.admin_users
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "user_acrpull" {
  for_each             = local.admin_users
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}
