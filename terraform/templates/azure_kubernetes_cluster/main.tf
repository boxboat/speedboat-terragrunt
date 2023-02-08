# Notes:
# "this" is used when it is the only resource of this type included in the template
# therefore no unique identifier is necessary.

locals {
  scope = lower(var.scope)
  safe_scope = replace(local.scope, "-", "")
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-aks-${local.scope}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${local.scope}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "spoke_virtual_network" {
  source = "../virtual_network_spoke"
  resource_group_name = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location
  scope = local.scope
  tags = var.tags
  address_space = var.address_space
  virtual_network_hub_name = var.virtual_network_hub_name
  virtual_network_hub_resource_group_name = var.virtual_network_hub_resource_group_name
  virtual_network_hub_id = var.virtual_network_hub_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_subnet" "appgw" {
  name                                             = "appgwSubnet"
  resource_group_name                              = module.spoke_virtual_network.virtual_network.resource_group_name
  virtual_network_name                             = module.spoke_virtual_network.virtual_network.name
  address_prefixes                                 = var.app_gateway_address_space
}

resource "azurerm_subnet" "aks" {
  name                                           = "aksSubnet"
  resource_group_name                            = module.spoke_virtual_network.virtual_network.resource_group_name
  virtual_network_name                           = module.spoke_virtual_network.virtual_network.name
  address_prefixes                               = var.aks_address_space
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_route_table" "route_table" {
  name                          = "rt-${local.scope}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_route_table_association" "rt_association" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.route_table.id
}

# # ACR name must be globally unique
resource "random_uuid" "acr" {}

resource "azurerm_container_registry" "this" {
  name                          = substr("acr${local.safe_scope}${replace(random_uuid.acr.result, "-", "")}", 0, 49)
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Standard"
  public_network_access_enabled = true
  admin_enabled                 = false
}

data "azurerm_monitor_diagnostic_categories" "acr" {
  resource_id = azurerm_container_registry.this.id
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name = azurerm_container_registry.this.name
  target_resource_id = azurerm_container_registry.this.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.acr.log_category_types
    content {
      category = enabled_log.key
      retention_policy {
        days = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.acr.metrics
    content {
      category = metric.key
      retention_policy {
        days = 30
        enabled =true
      }
    }
  }
}

resource "azurerm_key_vault" "this" {
  name                        = substr("kv-${local.scope}", 0, 23)
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

data "azurerm_monitor_diagnostic_categories" "kv" {
  resource_id = azurerm_key_vault.this.id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name = azurerm_key_vault.this.name
  target_resource_id = azurerm_key_vault.this.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.kv.log_category_types
    content {
      category = enabled_log.key
      retention_policy {
        days = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.kv.metrics
    content {
      category = metric.key
      retention_policy {
        days = 30
        enabled =true
      }
    }
  }
}

module "application_gateway" {
  source = "../application_gateway"
  resource_group_name = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location
  scope = local.scope
  subnet_id = azurerm_subnet.appgw.id
  virtual_network_name = module.spoke_virtual_network.virtual_network.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

locals {
  kubernetes_version = "1.24"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                    = "aks-${local.scope}"
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  azure_policy_enabled    = true
  kubernetes_version      = local.kubernetes_version
  node_resource_group = "${azurerm_resource_group.this.name}-managed"
  private_cluster_enabled = false
  private_cluster_public_fqdn_enabled = false
  dns_prefix = local.scope

  ingress_application_gateway {
    gateway_id = module.application_gateway.application_gateway.id
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  default_node_pool {
    name            = "defaultpool"
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    node_count      = 3
    only_critical_addons_enabled = true
    vnet_subnet_id  = azurerm_subnet.aks.id

    tags = var.tags
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "192.168.100.10"
    service_cidr       = "192.168.100.0/24"
    docker_bridge_cidr = "172.16.1.1/30"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled = true
  }

  identity {
    type         = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size = "Standard_D2s_v3"
  node_count = 3
  orchestrator_version = local.kubernetes_version
  vnet_subnet_id = azurerm_subnet.aks.id
  tags = var.tags
}

data "azurerm_monitor_diagnostic_categories" "aks" {
  resource_id = azurerm_kubernetes_cluster.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name = azurerm_kubernetes_cluster.this.name
  target_resource_id = azurerm_kubernetes_cluster.this.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.aks.log_category_types
    content {
      category = enabled_log.key
      retention_policy {
        days = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.aks.metrics
    content {
      category = metric.key
      retention_policy {
        days = 30
        enabled =true
      }
    }
  }
}

resource "azurerm_key_vault_access_policy" "aks_keyvault_policy" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.this.identity.0.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_role_assignment" "aks_acrpull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.identity.0.principal_id
}

# for configuring load balancing with Istio
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope = module.spoke_virtual_network.virtual_network.id
  role_definition_name = "Network Contributor"
  principal_id = azurerm_kubernetes_cluster.this.identity.0.principal_id
}

data "azuread_user" "admins" {
  for_each = toset(var.full_admin_users)
  user_principal_name = each.value
}

locals {
  admin_users = {for user in data.azuread_user.admins : user.user_principal_name => user.object_id }
}

resource "azurerm_role_assignment" "user_acrpush" {
  for_each = local.admin_users 
  scope = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id = each.value
}

resource "azurerm_role_assignment" "user_acrpull" {
  for_each = local.admin_users 
  scope = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id = each.value

}

resource "azurerm_role_assignment" "user_aks_cluster_admin" {
  for_each = local.admin_users 
  scope = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id = each.value
}

resource "azurerm_role_assignment" "user_aks_rbac_admin" {
  for_each = local.admin_users 
  scope = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id = each.value
}

resource "azurerm_role_assignment" "user_aks_rbac_cluster_admin" {
  for_each = local.admin_users 
  scope = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id = each.value
}

