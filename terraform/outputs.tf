output "server_id" {
  description = "ID of the created NetBox server"
  value       = sakuracloud_server.netbox.id
}

output "server_name" {
  description = "Name of the created NetBox server"
  value       = sakuracloud_server.netbox.name
}

output "internal_ip" {
  description = "Internal IP address of the server"
  value       = var.internal_nic_ip
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key for connecting to the server"
  value       = "${path.module}/../.ssh/id_ed25519"
}
