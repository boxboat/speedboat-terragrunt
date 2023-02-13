output "virtual_network" {
    value = azurerm_virtual_network.this
}

output "acr_private_dns_zone" {
    value = azurerm_private_dns_zone.acr-dns
}

output "kv_private_dns_zone" {
    value = azurerm_private_dns_zone.kv-dns
}