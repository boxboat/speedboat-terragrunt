locals {
  scope = lower(var.scope)
}

data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.location}-${local.scope}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = null
  tags                = var.tags

}

# Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${azurerm_virtual_network.this.name}-to-${var.virtual_network_hub_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.virtual_network_hub_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "${var.virtual_network_hub_name}-to-${azurerm_virtual_network.this.name}"
  resource_group_name          = var.virtual_network_hub_resource_group_name
  virtual_network_name         = var.virtual_network_hub_name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}