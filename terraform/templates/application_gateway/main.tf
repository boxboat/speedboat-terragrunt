resource "azurerm_network_security_group" "appgw-nsg" {
  name                = "appgw-nsg-${local.scope}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_network_security_rule" "inboundhttps" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
  name                        = "Allow443InBound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "inboundhttp" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
  name                        = "Allow80InBound"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "controlplane" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
  name                        = "AllowControlPlane"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "healthprobes" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
  name                        = "AllowHealthProbes"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "DenyAllInBound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
  name                        = "DenyAllInBound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "appgwsubnet" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.appgw-nsg.id
}

resource "azurerm_public_ip" "appgw" {
  name                = "appgw-pip-${local.scope}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_name      = "${var.virtual_network_name}-beap"
  frontend_port_name             = "${var.virtual_network_name}-feport"
  frontend_ip_configuration_name = "${var.virtual_network_name}-feip"
  http_setting_name              = "${var.virtual_network_name}-be-htst"
  listener_name                  = "${var.virtual_network_name}-httplstn"
  request_routing_rule_name      = "${var.virtual_network_name}-rqrt"
  redirect_configuration_name    = "${var.virtual_network_name}-rdrcfg"
}

resource "azurerm_application_gateway" "this" {
  name                = "appgtw-${local.scope}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # frontend_port {
  #   name     = "https-443"
  #   port     = 443
  #   protocol = "Https"
  # }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1 //priority arguement required as of 3.6.0 release. 1 is the highest priority and 20000 is the lowest priority.
  }
}