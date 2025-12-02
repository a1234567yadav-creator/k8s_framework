data "azurerm_subnet" "aks_subnet" {
  for_each             = var.aks_clusters
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

locals {
  aks_maintenance_window = {
    for k, v in var.aks_clusters :
    k => lookup(v, "maintenance_window", null)
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = var.aks_clusters
  name                = each.value.cluster_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix
  kubernetes_version  = try(each.value.kubernetes_version, null)
  private_cluster_enabled         = try(each.value.private_cluster_enabled, false)
  role_based_access_control_enabled = true
  disk_encryption_set_id = try(each.value.disk_encryption_set_id, null)
  azure_policy_enabled = try(each.value.enable_azure_policy, false)

  dynamic "api_server_access_profile" {
    for_each = (!try(each.value.private_cluster_enabled, false) && length(try(each.value.api_server_authorized_ip_ranges, [])) > 0) ? [1] : []
    content {
      authorized_ip_ranges = each.value.api_server_authorized_ip_ranges
    }
  }

  default_node_pool {
    name            = "agentpool"
    node_count      = each.value.agent_count
    vm_size         = each.value.vm_size
    vnet_subnet_id  = data.azurerm_subnet.aks_subnet[each.key].id
    max_pods        = try(each.value.node_pool_max_pods, 30)
    zones           = try(each.value.node_pool_availability_zones, [])
  }
  network_profile {
    network_plugin = try(each.value.network_plugin, "azure")
    network_policy = try(each.value.network_policy, null)
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = try(each.value.azure_ad_integrated, true) ? [1] : []
    content {
      managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = try(each.value.admin_group_object_ids, [])
    }
  }

  maintenance_window {
    allowed {
      day   = local.aks_maintenance_window[each.key] != null ? local.aks_maintenance_window[each.key].day_of_week : null
      hours = local.aks_maintenance_window[each.key] != null ? [local.aks_maintenance_window[each.key].start_hour] : []
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = each.value.tags
  local_account_disabled = try(each.value.local_account_disabled, false)
}