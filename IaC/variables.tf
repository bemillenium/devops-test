variable "project_id" {
  type = string
  description = "The project ID to host the network in"
}
variable "vpc_network_name" {
  type = string
  description = "The project ID to host the network in"
  default = "vpn-network"
}
variable "vpc_network_subnet_name" {
  type = string
  description = "The project ID to host the network in"
  default = "vpn-network-subnet"
}
variable "vpc_network_subnet_network_cidr" {
  type = string
  description = "The project ID to host the network in"
  default = "10.0.0.0/8"
}
variable "vpc_network_subnet_network_region" {
  type = string
  description = "The project ID to host the network in"
  default = "asia-southeast1"
}

variable "gke_cluster_name" {
  type = string
  description = "The name of the cluster, unique within the project and zone."
}
variable "gke_zone" {
  type = string
  description = "The name of the cluster, unique within the project and zone."
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
  description = "The name of the cluster, unique within the project and zone."
}
variable "gke_services_ipv4_cidr_block" {
  type = string
  description = "The name of the cluster, unique within the project and zone."
}
variable "gke_master_ipv4_cidr_block" {
  type = string
  description = "The name of the cluster, unique within the project and zone."
}
variable "gke_preemptible_node" {
  type = string
  default = "false"
  description = "The name of the cluster, unique within the project and zone."
}

variable "node_pools" {
  type = list(map(string))
}

variable "vpn_instance" {
  type = map(string)
}