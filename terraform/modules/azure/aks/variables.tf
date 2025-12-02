variable "aks_clusters" {
  description = "Map of AKS clusters and their properties"
  type = map(object({
    resource_group_name           = string
    location                     = string
    cluster_name                 = string
    dns_prefix                   = string
    agent_count                  = number
    vm_size                      = string
    vnet_name                    = string
    subnet_name                  = string
    tags                         = map(string)
    kubernetes_version           = optional(string)
    api_server_authorized_ip_ranges = optional(list(string), [])
    private_cluster_enabled       = optional(bool, false)
    node_pool_max_pods            = optional(number, 30)
    node_pool_availability_zones  = optional(list(string), [])
    network_plugin                = optional(string, "azure")
    network_policy                = optional(string)
    enable_azure_policy           = optional(bool, false)
    enable_monitoring             = optional(bool, true)
    admin_group_object_ids        = optional(list(string), [])
    disk_encryption_set_id        = optional(string)
    maintenance_window            = optional(object({
      day_of_week = string
      start_hour  = number
      duration    = number
    }))
    azure_ad_integrated    = optional(bool, true)
    local_account_disabled = optional(bool, false)
  }))
}