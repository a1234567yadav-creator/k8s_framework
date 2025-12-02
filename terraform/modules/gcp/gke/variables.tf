variable "gke_clusters" {
  description = "Map of GKE clusters and their configuration."
  type = map(object({
    cluster_name       = string
    region             = string
    initial_node_count = number
    node_count         = number
    node_machine_type  = string
    node_labels        = optional(map(string), {})
    node_tags          = optional(list(string), [])
    preemptible        = optional(bool, false)
    disk_size_gb       = optional(number, 100)
    network_name       = string
    subnetwork_name    = string
    release_channel    = optional(string, "REGULAR")
    enable_private_nodes = optional(bool, false)
    master_authorized_networks = optional(list(object({
      cidr_block   = string
      display_name = string
    })), [])
    logging_service    = optional(string, "logging.googleapis.com/kubernetes")
    monitoring_service = optional(string, "monitoring.googleapis.com/kubernetes")
    tags               = optional(map(string), {})
  }))
}