provider "null" {
  version = "~> 2.1"
}

provider "google" {
  version = "~> 3.45.0"
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
  region        = "us-central1"
  network       = "test-vpc-network"
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}