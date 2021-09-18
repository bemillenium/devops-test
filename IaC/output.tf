output "vpn_ip_addr" {
  value = google_compute_address.static.address
}