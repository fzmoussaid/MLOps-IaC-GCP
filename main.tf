provider "google" {
  project = var.project_name
  region  = "us-central1"
}


resource "google_container_cluster" "vegetables_cluster_IaC" {
  name     = "vegetables-cluster-iac"
  location = "us-central1"

  initial_node_count = 1

  network    = google_compute_network.vegetables_network.id
  subnetwork = google_compute_subnetwork.vegetables_subnetwork.id

  node_config {
    service_account = "default"
    oauth_scopes    = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }


  deletion_protection = false
}

resource "google_compute_network" "vegetables_network" {
  name = "vegetables-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "vegetables_subnetwork" {
  name = "vegetables-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"

  network = google_compute_network.vegetables_network.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}


