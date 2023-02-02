locals {
  vnet_lookups = merge([for pairing in var.hub_peering_pairs : { "${pairing.source_vnet_resource_group_name}-${pairing.source_vnet_name}" = {
    vnet_name                = pairing.source_vnet_name
    vnet_resource_group_name = pairing.source_vnet_resource_group_name
    },
    "${pairing.destination_vnet_resource_group_name}-${pairing.destination_vnet_name}" = {
      vnet_name                = pairing.destination_vnet_name
      vnet_resource_group_name = pairing.destination_vnet_resource_group_name
    }
  }]...)
}

data "azurerm_virtual_network" "this" {
  for_each            = local.vnet_lookups
  name                = each.value.vnet_name
  resource_group_name = each.value.vnet_resource_group_name
}

locals {
  pairings = merge([for pairing in var.hub_peering_pairs : {
    "${pairing.source_vnet_name}-to-${pairing.destination_vnet_name}" = {
      source_vnet_name                = pairing.source_vnet_name
      source_vnet_resource_group_name = pairing.source_vnet_resource_group_name
      destination_vnet_id             = data.azurerm_virtual_network.this["${pairing.destination_vnet_resource_group_name}-${pairing.destination_vnet_name}"].id
      destination_vnet_name           = pairing.destination_vnet_name
    }
    "${pairing.destination_vnet_name}-to-${pairing.source_vnet_name}" = {
      source_vnet_name                = pairing.destination_vnet_name
      source_vnet_resource_group_name = pairing.destination_vnet_resource_group_name
      destination_vnet_id             = data.azurerm_virtual_network.this["${pairing.source_vnet_resource_group_name}-${pairing.source_vnet_name}"].id
      destination_vnet_name           = pairing.source_vnet_name
    }
  }]...)
}

resource "azurerm_virtual_network_peering" "this" {
  for_each                     = local.pairings
  name                         = each.key
  resource_group_name          = each.value.source_vnet_resource_group_name
  virtual_network_name         = each.value.source_vnet_name
  remote_virtual_network_id    = each.value.destination_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}



# # Spoke to Hub
# resource "azurerm_virtual_network_peering" "spoke_to_hub" {
#   name                         = "${azurerm_virtual_network.this.name}-to-${var.virtual_network_hub_name}"
#   resource_group_name          = var.resource_group_name
#   virtual_network_name         = azurerm_virtual_network.this.name
#   remote_virtual_network_id    = var.virtual_network_hub_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
# }

# # Hub to Spoke
# resource "azurerm_virtual_network_peering" "hub_to_spoke" {
#   name                         = "${var.virtual_network_hub_name}-to-${azurerm_virtual_network.this.name}"
#   resource_group_name          = var.virtual_network_hub_resource_group_name
#   virtual_network_name         = var.virtual_network_hub_name
#   remote_virtual_network_id    = azurerm_virtual_network.this.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
# }
