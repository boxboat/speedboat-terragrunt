# Notes:
# "this" is used when it is the only resource of this type included in the template
# therefore no unique identifier is necessary.

resource "azurerm_kubernetes_cluster" "this" {
  name                                = "aks-${var.scope}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  azure_policy_enabled                = true
  kubernetes_version                  = "1.24"
  node_resource_group                 = "${var.resource_group_name}-managed"
  private_cluster_enabled             = false
  private_cluster_public_fqdn_enabled = false
  dns_prefix                          = var.scope

  # oms_agent {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  # }

  default_node_pool {
    name            = "defaultpool"
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    node_count      = 2

    tags = var.tags
  }

  network_profile {
    network_plugin = "azure"
    # dns_service_ip     = "192.168.100.10"
    # service_cidr       = "192.168.100.0/24"
    # docker_bridge_cidr = "172.16.1.1/30"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  identity {
    type = "SystemAssigned"
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

resource "azurerm_role_assignment" "aks_acrpull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.identity.0.principal_id
}

data "azuread_user" "admins" {
  for_each            = toset(var.full_admin_users)
  user_principal_name = each.value
}

locals {
  admin_users = { for user in data.azuread_user.admins : user.user_principal_name => user.object_id }
}

resource "azurerm_role_assignment" "user_aks_cluster_admin" {
  for_each             = local.admin_users
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "user_aks_rbac_admin" {
  for_each             = local.admin_users
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "user_aks_rbac_cluster_admin" {
  for_each             = local.admin_users
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}

