provider "null" {
  version = "~> 2.1"
}

provider "google" {
  version = "~> 3.45.0"
  credentials = file("credential.json")
  project       = var.project_id
}

# [START vpc_custom_create]
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id # Replace this with your project ID in quotes
  name                    = "millenium-oozou"
  auto_create_subnetworks = false
  mtu                     = 1460
}


resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  project       = var.project_id # Replace this with your project ID in quotes
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-southeast1"
  network       = "millenium-oozou"
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name               = "marcellus-wallace"
  location           = "us-central1-a"
  initial_node_count = 1
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      foo = "bar"
    }
    tags = ["foo", "bar"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

