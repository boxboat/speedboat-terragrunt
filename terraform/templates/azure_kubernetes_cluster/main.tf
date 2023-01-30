# Notes:
# "this" is used when it is the only resource of this type included in the template
# therefore no unique identifier is necessary.


locals {
    scope = lower(var.scope)
}

resource "azurerm_resource_group" "this" {
  name     = "rg-aks-${local.scope}"
  location = var.location
  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.scope}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
  dns_servers         = null
  tags                = var.tags
}

# Remainder of firewall configureation is located in firewall.tf
resource "azurerm_subnet" "firewall" {
  name                                           = "AzureFirewallSubnet"
  resource_group_name                            = azurerm_resource_group.this.name
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = ["10.0.1.0/26"]
  enforce_private_link_endpoint_network_policies = false
}
