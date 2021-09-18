project_id = "mimetic-surf-230708"
vpc_network_name = "millenium-oozou"
vpc_network_subnet_name = "millenium-oozou-develop"
vpc_network_subnet_network_cidr = "10.4.0.0/18"

vpn_instance = {
  machine_type = "n1-standard-1"
  zone = "asia-southeast1-a"
}

gke_cluster_name = "gke-millenium-oozou"
gke_cluster_ipv4_cidr_block = "10.6.0.0/16"
gke_services_ipv4_cidr_block = "10.7.0.0/19"
gke_master_ipv4_cidr_block = "10.7.32.0/28"
gke_preemptible_node = "true"
node_pools = [
  {
    name                       = "general"
    initial_node_count         = 1
    autoscaling_min_node_count = 1
    autoscaling_max_node_count = 1
    node_config_machine_type   = "n1-standard-1"
    node_config_disk_type      = "pd-standard"
    node_config_disk_size_gb   = 40
    node_config_preemptible    = true
  },
]