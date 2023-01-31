resource "azurerm_public_ip" "firewall" {
  name                 = "${azurerm_virtual_network.this.name}-firewall-pip"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  allocation_method    = "Static"
  sku                  = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "${azurerm_virtual_network.this.name}-firewall"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  firewall_policy_id  = azurerm_firewall_policy.aks.id
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_route_table" "route_table" {
  name                          = "rt-${local.scope}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  disable_bgp_route_propagation = false

  route {
    name                   = "route_to_firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.4"
  }
}

resource "azurerm_firewall_policy" "aks" {
  name                = "AKSpolicy"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_firewall_policy_rule_collection_group" "aks" {
  name               = "aks-rcg"
  firewall_policy_id = azurerm_firewall_policy.aks.id
  priority           = 200
  application_rule_collection {
    name     = "aks_app_rules"
    priority = 205
    action   = "Allow"
    rule {
      name = "aks_service"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses      = ["10.0.16.0/20"]
      destination_fqdn_tags = ["AzureKubnernetesService"]
    }
  }

  network_rule_collection {
    name     = "aks_network_rules"
    priority = 201
    action   = "Allow"
    rule {
      name                  = "https"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.16.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "dns"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.16.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "time"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.16.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
    rule {
      name                  = "tunnel_udp"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.16.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["1194"]
    }
    rule {
      name                  = "tunnel_tcp"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.16.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["9000"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "aks2" {
  name               = "aks-rcg-2"
  firewall_policy_id = azurerm_firewall_policy.aks.id
  priority           = 210
  application_rule_collection {
    name     = "aks_app_rules"
    priority = 215
    action   = "Allow"
    rule {
      name = "aks_service"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses      = ["10.0.32.0/20"]
      destination_fqdn_tags = ["AzureKubnernetesService"]
    }
  }

  network_rule_collection {
    name     = "aks_network_rules"
    priority = 211
    action   = "Allow"
    rule {
      name                  = "https"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.32.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "dns"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.32.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "time"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.32.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
    rule {
      name                  = "tunnel_udp"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.32.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["1194"]
    }
    rule {
      name                  = "tunnel_tcp"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.32.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["9000"]
    }
  }
}