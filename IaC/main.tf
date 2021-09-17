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
  name          = "millenium-oozou-vm"
  ip_cidr_range = "10.4.0.0/18"
  region        = "asia-southeast1"
  network       = "millenium-oozou"
  # secondary_ip_range {
  #   range_name    = "tf-test-secondary-range-update1"
  #   ip_cidr_range = "192.168.10.0/24"
  # }
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

# resource "google_container_cluster" "primary" {
#   name               = "marcellus-wallace"
#   location           = "us-central1-a"
#   initial_node_count = 1
#   node_config {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.default.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#     labels = {
#       foo = "bar"
#     }
#     tags = ["foo", "bar"]
#   }
#   timeouts {
#     create = "30m"
#     update = "40m"
#   }
# }
resource "google_container_cluster" "primary" {
  name               = "marcellus-wallace"
  location           = "asia-southeast1-a"
  initial_node_count = 1
  # remove_default_node_pool = true
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  network                       = "millenium-oozou"
  subnetwork                    = "millenium-oozou-vm"

  ip_allocation_policy {
    # cluster_secondary_range_name  = "gke-cluster-subnet"
    # services_secondary_range_name = "gke-subnet-subnet"
    cluster_ipv4_cidr_block = "10.6.0.0/16"
    services_ipv4_cidr_block = "10.8.0.0/19"
  }

  private_cluster_config {
      enable_private_nodes = "true"
      enable_private_endpoint = "true"
      master_ipv4_cidr_block = "10.7.32.0/28"
  }
  
  node_config {
    preemptible = "true"
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

# VPN and firewall
resource "google_compute_firewall" "internal" {
 name    = "millenium-oozou-allow-internal"
 network = "millenium-oozou"

 allow {
   protocol = "tcp"
   ports    = ["22"]
 }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.0.0/8"]
}
resource "google_compute_firewall" "default" {
 name    = "millenium-oozou-allow-vpn"
 network = "millenium-oozou"

 allow {
   protocol = "tcp"
   ports    = ["22"]
 }
  allow {
   protocol = "udp"
   ports    = ["1194"]
 }
}
resource "google_compute_instance" "default" {
 name         = "millenium-vpn"
 machine_type = "f1-micro"
 zone         = "asia-southeast1-a"
 tags         = ["millenium-oozou-allow-vpn"]
 metadata = {
   ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
 }
 boot_disk {
   initialize_params {
     image = "ubuntu-os-cloud/ubuntu-2004-lts"
   }
 }

// Make sure flask is installed on all new instances for later steps
#  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "millenium-oozou"
   subnetwork = "millenium-oozou-vm"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}