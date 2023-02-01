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

# resource "azurerm_route_table" "route_table" {
#   name                          = "rt-${var.lz_prefix}"
#   resource_group_name           = azurerm_resource_group.spoke-rg.name
#   location                      = azurerm_resource_group.spoke-rg.location
#   disable_bgp_route_propagation = false

#   route {
#     name                   = "route_to_firewall"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.0.1.4"
#   }
# }

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


# # Deploy DNS Private Zone for ACR

resource "azurerm_private_dns_zone" "acr-dns" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "vnet-to-acr"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr-dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# # Deploy DNS Private Zone for KV

resource "azurerm_private_dns_zone" "kv-dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "vnet-to-keyvault"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv-dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
}