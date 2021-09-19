variable "project_id" {
  type = string
  description = "The project ID to host the network in"
}
variable "vpc_network_name" {
  type = string
  description = "The VPC network name"
  default = "vpn-network"
}
variable "vpc_network_subnet_name" {
  type = string
  description = "The VPC subnet name"
  default = "vpn-network-subnet"
}
variable "vpc_network_subnet_network_cidr" {
  type = string
  description = "The CIDR of the subnet"
  default = "10.0.0.0/8"
}
variable "vpc_network_subnet_network_region" {
  type = string
  description = "The region of the subnet in the VPC network"
  default = "asia-southeast1"
}

variable "gke_cluster_name" {
  type = string
  description = "The name of the cluster, unique within the project and zone."
}
variable "gke_zone" {
  type = string
  description = "The GKE zone that the master is located"
  default = "asia-southeast1-a"
}
variable "gke_master_authorized_networks_cidr_blocks" {
  type = list(map(string))

  default = [
    {
      # External network that can access Kubernetes master through HTTPS. Must
      # be specified in CIDR notation. This block should allow access from any
      # address, but is given explicitly to prevent Google's defaults from
      # fighting with Terraform.
      cidr_block = "10.0.0.0/8"
      # Field for users to identify CIDR blocks.
      display_name = "default"
    },
  ]

  description = ""
}
variable "gke_cluster_ipv4_cidr_block" {
  type = string
  description = "The CIDR of the pod is used."
}
variable "gke_services_ipv4_cidr_block" {
  type = string
  description = "The CIDR of the service is used."
}
variable "gke_master_ipv4_cidr_block" {
  type = string
  description = "The IP of the GKE master node"
}
variable "gke_preemptible_node" {
  type = string
  default = "false"
  description = "The preemtible is allowed the Workers to be stop in by 24 hr, less cost consume. Don't enabled this in Production mode"
}

variable "node_pools" {
  type = list(map(string))
}
# Example of node_pools
# node_pools = [
#   {
#     name                       = "general"
#     initial_node_count         = 1
#     autoscaling_min_node_count = 1
#     autoscaling_max_node_count = 1
#     node_config_machine_type   = "n1-standard-1"
#     node_config_disk_type      = "pd-standard"
#     node_config_disk_size_gb   = 40
#     node_config_preemptible    = true
#   },
# ]

variable "vpn_instance" {
  type = map(string)
}
# Example of vpn_instance
# vpn_instance = {
#   machine_type = "n1-standard-1"
#   zone = "asia-southeast1-a"
# }