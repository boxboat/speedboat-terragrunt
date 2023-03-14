output "container_registry" {
  value     = azurerm_container_registry.this
  sensitive = true
}
