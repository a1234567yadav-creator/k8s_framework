
output "gke_cluster_names" {
  value = { for k, v in google_container_cluster.gke : k => v.name }
}

output "gke_endpoints" {
  value = { for k, v in google_container_cluster.gke : k => v.endpoint }
}

output "gke_master_versions" {
  value = { for k, v in google_container_cluster.gke : k => v.master_version }
}