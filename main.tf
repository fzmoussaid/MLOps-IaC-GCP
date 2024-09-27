provider "google" {
  project = var.project_name
  region  = "us-central1"
}


resource "google_container_cluster" "vegetables_cluster_IaC" {
  name     = "vegetables-cluster-iac"
  location = "us-central1"

  initial_node_count = 1

  node_config {
    service_account = "default"
    oauth_scopes    = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }


  deletion_protection = false
}



