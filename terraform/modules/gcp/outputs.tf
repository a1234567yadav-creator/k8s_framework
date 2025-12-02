output "gke_cluster_name" {
  value = google_container_cluster.gke.name
}

output "gke_network" {
  value = google_compute_network.gke_network.name
}

output "gke_subnetwork" {
  value = google_compute_subnetwork.gke_subnetwork.name
}

output "gke_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "gke_master_version" {
  value = google_container_cluster.gke.master_version
}