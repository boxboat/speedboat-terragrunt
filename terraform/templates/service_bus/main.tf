data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
    name = var.resource_group_name
}

locals {
    tags = merge(
        data.azurerm_resource_group.this.tags,
        var.tags
    )
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "sbus-${var.scope}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "Standard"

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}