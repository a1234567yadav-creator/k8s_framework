resource "google_compute_network" "gke_vpc" {
  for_each                = var.networks
  name                    = each.value.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  for_each      = var.subnetworks
  name          = each.value.subnetwork_name
  ip_cidr_range = each.value.subnetwork_cidr
  region        = each.value.region
  network       = google_compute_network.gke_vpc[each.value.network_key].id
}

resource "google_compute_firewall" "gke_firewall_ssh" {
  for_each = var.networks
  name     = "${each.value.network_name}-allow-ssh"
  network  = google_compute_network.gke_vpc[each.key].id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "gke_firewall_https" {
  for_each = var.networks
  name     = "${each.value.network_name}-allow-https"
  network  = google_compute_network.gke_vpc[each.key].id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}