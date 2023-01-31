resource "azurerm_network_security_group" "aks-nsg" {
  name                = "${azurerm_virtual_network.this.name}-${azurerm_subnet.aks.name}-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks-nsg.id
}

# # Associate Route Table to AKS Subnet
resource "azurerm_subnet_route_table_association" "rt_association" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.route_table.id
}


resource "azurerm_network_security_group" "aks2-nsg" {
  name                = "${azurerm_virtual_network.this.name}-${azurerm_subnet.aks2.name}-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_subnet_network_security_group_association" "subnet2" {
  subnet_id                 = azurerm_subnet.aks2.id
  network_security_group_id = azurerm_network_security_group.aks2-nsg.id
}

# # Associate Route Table to aks2 Subnet
resource "azurerm_subnet_route_table_association" "rt_association2" {
  subnet_id      = azurerm_subnet.aks2.id
  route_table_id = azurerm_route_table.route_table.id
}