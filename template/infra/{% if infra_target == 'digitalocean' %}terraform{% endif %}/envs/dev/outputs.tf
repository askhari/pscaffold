output "host_ip" {
  description = "Set this as DEPLOY_HOST in the dev GitHub environment."
  value       = module.host.ip_address
}
