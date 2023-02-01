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

# resource "azurerm_subnet" "firewall" {
#   name                                           = "AzureFirewallSubnet"
#   resource_group_name                            = azurerm_resource_group.rg.name
#   virtual_network_name                           = azurerm_virtual_network.vnet.name
#   address_prefixes                               = ["10.0.1.0/26"]
#   enforce_private_link_endpoint_network_policies = false

# }

# resource "azurerm_subnet" "gateway" {
#   name                                           = "GatewaySubnet"
#   resource_group_name                            = azurerm_resource_group.rg.name
#   virtual_network_name                           = azurerm_virtual_network.vnet.name
#   address_prefixes                               = ["10.0.2.0/27"]
#   enforce_private_link_endpoint_network_policies = false

# }

# resource "azurerm_firewall" "firewall" {
#   name                = "${azurerm_virtual_network.vnet.name}-firewall"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   firewall_policy_id  = module.firewall_rules_aks.fw_policy_id
#   sku_name            = var.sku_name
#   sku_tier            = var.sku_tier

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.firewall.id
#     public_ip_address_id = azurerm_public_ip.firewall.id
#   }
# }

# resource "azurerm_public_ip" "firewall" {
#   name                 = "${azurerm_virtual_network.vnet.name}-firewall-pip"
#   resource_group_name  = azurerm_resource_group.rg.name
#   location             = azurerm_resource_group.rg.location
#   allocation_method    = "Static"
#   sku                  = "Standard"
# }

# resource "azurerm_firewall_policy" "aks" {
#   name                = "AKSpolicy"
#   resource_group_name = var.resource_group_name
#   location            = var.location
# }

# Rules Collection Group

# resource "azurerm_firewall_policy_rule_collection_group" "AKS" {
#   name               = "aks-rcg"
#   firewall_policy_id = azurerm_firewall_policy.aks.id
#   priority           = 200
#   application_rule_collection {
#     name     = "aks_app_rules"
#     priority = 205
#     action   = "Allow"
#     rule {
#       name = "aks_service"
#       protocols {
#         type = "Https"
#         port = 443
#       }
#       source_addresses      = ["10.1.0.0/16"]
#       destination_fqdn_tags = ["AzureKubnernetesService"]
#     }
#   }

#   network_rule_collection {
#     name     = "aks_network_rules"
#     priority = 201
#     action   = "Allow"
#     rule {
#       name                  = "https"
#       protocols             = ["TCP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["*"]
#       destination_ports     = ["443"]
#     }
#     rule {
#       name                  = "dns"
#       protocols             = ["UDP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["*"]
#       destination_ports     = ["53"]
#     }
#     rule {
#       name                  = "time"
#       protocols             = ["UDP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["*"]
#       destination_ports     = ["123"]
#     }
#     rule {
#       name                  = "tunnel_udp"
#       protocols             = ["UDP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["*"]
#       destination_ports     = ["1194"]
#     }
#     rule {
#       name                  = "tunnel_tcp"
#       protocols             = ["TCP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["*"]
#       destination_ports     = ["9000"]
#     }
#   }

# }