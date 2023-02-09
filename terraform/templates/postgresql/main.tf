data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
    name = var.resource_group_name
}

locals {
    tags = merge(
        data.azurerm_resource_group.this.tags,
        var.tags
    )
}

resource "random_password" "postgres_server" {
    length = 20
    special = true
}

resource "azurerm_postgresql_server" "this" {
    name = "pgsrv-${var.scope}"
    location = data.azurerm_resource_group.this.location
    resource_group_name = data.azurerm_resource_group.this.name
    sku_name = var.sku_name
    version = var.server_version
    ssl_enforcement_enabled = true

    administrator_login = "psqladmin"
    administrator_login_password = random_password.postgres_server.result

    identity {
        type = "SystemAssigned"
    }

    tags = local.tags
}

data "azuread_user" "aad_admin" {
    user_principal_name = var.aad_server_administrator
}

resource "azurerm_postgresql_active_directory_administrator" "this" {
    server_name = azurerm_postgresql_server.this.name
    resource_group_name = data.azurerm_resource_group.this.name
    login = "sqladmin"
    object_id = data.azuread_user.aad_admin.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_postgresql_database" "this" {
    name = "psqldb-${var.scope}"
    resource_group_name = data.azurerm_resource_group.this.name
    server_name = azurerm_postgresql_server.this.name
    charset = "UTF8"
    collation = "English_United States.1252"
}