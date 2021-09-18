provider "google" {
  version = "~> 3.5"
  credentials = file("credential.json")
  project       = var.project_id
  region = var.vpc_network_subnet_network_region
}
# VPC Network
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}
resource "google_compute_router" "router" {
  name                          = "millenium-oozou-router"
  network                       = google_compute_network.vpc_network.name
}
resource "google_compute_router_nat" "nat" {
  name                               = "millenium-oozou-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Subnetwork
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  project       = var.project_id
  name          = var.vpc_network_subnet_name
  ip_cidr_range = var.vpc_network_subnet_network_cidr
  region        = var.vpc_network_subnet_network_region
  network       = google_compute_network.vpc_network.id
}
# Service Account for GKE
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

# GKE
resource "google_container_cluster" "primary" {
  name               = var.gke_cluster_name
  location           = var.gke_zone
  initial_node_count = 1
  remove_default_node_pool = true
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.gke_master_authorized_networks_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  network                       = google_compute_network.vpc_network.name #var.vpc_network_name
  subnetwork                    = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.gke_cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.gke_services_ipv4_cidr_block
  }

  private_cluster_config {
      enable_private_nodes = "true"
      enable_private_endpoint = "true"
      master_ipv4_cidr_block = var.gke_master_ipv4_cidr_block
  }
  
  node_config {
    preemptible = var.gke_preemptible_node
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

resource "google_container_node_pool" "node_pool" {
  location = google_container_cluster.primary.location
  count = length(var.node_pools)
  name = format("%s-pool", lookup(var.node_pools[count.index], "name", format("%03d", count.index + 1)))
  cluster = google_container_cluster.primary.name
  initial_node_count = lookup(var.node_pools[count.index], "initial_node_count", 1)
  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = lookup(var.node_pools[count.index], "autoscaling_min_node_count", 2)

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = lookup(var.node_pools[count.index], "autoscaling_max_node_count", 3)
    # version = 
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  node_config {
    preemptible = lookup(
      var.node_pools[count.index],
      "node_config_preemptible",
      false,
    )
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    machine_type = lookup(
      var.node_pools[count.index],
      "node_config_machine_type",
      "n1-standard-1",
    )
    disk_size_gb = lookup(
      var.node_pools[count.index],
      "node_config_disk_size_gb",
      100
    )
    disk_type = lookup(
      var.node_pools[count.index],
      "node_config_disk_type",
      "pd-standard",
    )
    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }
  }
  timeouts {
    create = "30m"
    update = "40m"
  }

}

# Firewall
resource "google_compute_firewall" "internal" {
 name    = "millenium-oozou-allow-internal"
 network = google_compute_network.vpc_network.name

 allow {
   protocol = "tcp"
   ports    = ["22"]
 }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "vpn" {
 name    = "millenium-oozou-allow-vpn"
 network = google_compute_network.vpc_network.name
 allow {
   protocol = "tcp"
   ports    = ["22"]
 }
  allow {
   protocol = "udp"
   ports    = ["1194"]
 }
}
resource "google_compute_address" "static" {
  name = "vpn-static-ip"
}
# VPN Instance
resource "google_compute_instance" "vpn-instance" {
 name         = "millenium-vpn"
 machine_type = lookup(var.vpn_instance, "machine_type", "f1-micro")
 zone         = lookup(var.vpn_instance, "zone", "asia-southeast1-a")
 tags         = ["millenium-oozou-allow-vpn"]
 metadata = {
   ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
 }
 scheduling {
   preemptible = true
   automatic_restart = false
 }
 boot_disk {
   initialize_params {
     image = "ubuntu-os-cloud/ubuntu-2004-lts"
   }
 }
 network_interface {
   network = google_compute_network.vpc_network.name
   subnetwork = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name

   access_config {
     nat_ip = google_compute_address.static.address
     // Include this section to give the VM an external ip address
   }
 }
}

# IAM roles for developers
resource "google_service_account" "cluster_service_account" {
  project      = var.project_id
  account_id   = "developer-service-account-demo"
  display_name = "Terraform-managed service account for cluster"
}
resource "google_project_iam_member" "cluster_service_account-developer" {
  project = google_service_account.cluster_service_account.project
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}
resource "google_project_iam_member" "cluster_service_account-cluster-viewer" {
  project = google_service_account.cluster_service_account.project
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}
resource "google_project_iam_member" "cluster_service_account-viewer" {
  project = google_service_account.cluster_service_account.project
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}
