resource "google_container_cluster" "gke" {
  for_each = var.gke_clusters

  name     = each.value.cluster_name
  location = each.value.region

  # initial_node_count removed because remove_default_node_pool = true

  network    = each.value.network_name
  subnetwork = each.value.subnetwork_name

  private_cluster_config {
    enable_private_nodes = lookup(each.value, "enable_private_nodes", false)
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(lookup(each.value, "master_authorized_networks", [])) > 0 ? {
      nets = lookup(each.value, "master_authorized_networks", [])
    } : {}

    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.nets
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  release_channel {
    channel = lookup(each.value, "release_channel", "REGULAR")
  }

  logging_service    = lookup(each.value, "logging_service", "logging.googleapis.com/kubernetes")
  monitoring_service = lookup(each.value, "monitoring_service", "monitoring.googleapis.com/kubernetes")

  lifecycle {
    # Prevent accidental deletion of the GKE cluster; set to true for safety.
    prevent_destroy = true
  }

  remove_default_node_pool = true
}

resource "google_container_node_pool" "default" {
  for_each   = var.gke_clusters
  name       = "${each.value.cluster_name}-node-pool"
  location   = each.value.region
  cluster    = google_container_cluster.gke[each.key].name
  node_count = each.value.node_count

  node_config {
    machine_type = each.value.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels      = lookup(each.value, "node_labels", {})
    tags        = lookup(each.value, "node_tags", [])
    preemptible = lookup(each.value, "preemptible", false)
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
