output "ip_address" {
  description = "Public reserved IP of the host (use it for DEPLOY_HOST and DNS)."
  value       = digitalocean_reserved_ip.this.ip_address
}

output "droplet_id" {
  description = "Droplet ID."
  value       = digitalocean_droplet.this.id
}
