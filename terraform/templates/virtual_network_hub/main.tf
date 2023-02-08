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

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${local.scope}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.location}-${local.scope}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.address_space
  dns_servers         = null
  tags                = var.tags
}

data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = azurerm_virtual_network.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name = azurerm_virtual_network.this.name
  target_resource_id = azurerm_virtual_network.this.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.this.log_category_types
    content {
      category = enabled_log.key
      retention_policy {
        days = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.this.metrics
    content {
      category = metric.key
      retention_policy {
        days = 30
        enabled =true
      }
    }
  }
}

# # Deploy DNS Private Zone for ACR

resource "azurerm_private_dns_zone" "acr-dns" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "vnet-to-acr"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.acr-dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# # Deploy DNS Private Zone for KV

resource "azurerm_private_dns_zone" "kv-dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "vnet-to-keyvault"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.kv-dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
}