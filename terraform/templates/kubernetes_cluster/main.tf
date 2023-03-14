# # ACR name must be globally unique
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.scope}"
  location = var.location
  tags     = var.tags
}

module "aks" {
  source                = "../../modules/azure_kubernetes_cluster"
  scope                 = var.scope
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  tags                  = var.tags
  full_admin_users      = var.full_admin_users
  container_registry_id = var.container_registry_id
}
