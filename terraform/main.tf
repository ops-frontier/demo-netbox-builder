terraform {
  required_version = ">= 1.0"
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2.25"
    }
  }
}

provider "sakuracloud" {
  token  = var.sakuracloud_access_token
  secret = var.sakuracloud_access_token_secret
  zone   = var.sakuracloud_zone
}

# Get the latest Ubuntu image
data "sakuracloud_archive" "ubuntu" {
  os_type = "ubuntu2204"
}

# SSH public key resource
resource "sakuracloud_ssh_key" "netbox_key" {
  name       = "netbox-builder-key"
  public_key = file("${path.module}/../.ssh/id_ed25519.pub")
}

# Get existing switch by name
data "sakuracloud_switch" "internal" {
  filter {
    names = [var.internal_switch_name]
  }
}

# Startup script for network configuration
resource "sakuracloud_note" "netbox_init" {
  name  = "netbox-init-script"
  class = "shell"
  content = <<-EOT
    #!/bin/bash
    set -e

    # Wait for network to be ready
    sleep 5

    # Configure static IP address
    cat > /etc/netplan/99-sakura-custom.yaml <<EOF
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: no
          addresses:
            - ${var.internal_nic_ip}
    EOF

    chmod 600 /etc/netplan/99-sakura-custom.yaml
    netplan apply
  EOT
}

# Server resource
resource "sakuracloud_server" "netbox" {
  name        = "netbox-server"
  core        = 2
  memory      = 4
  description = "NetBox server managed by Terraform"

  # Network interface connected to the internal switch
  network_interface {
    upstream = data.sakuracloud_switch.internal.id
  }

  # Disk configuration
  disks = [sakuracloud_disk.netbox.id]

  # Disk edit parameters for SSH key and startup script
  disk_edit_parameter {
    ssh_key_ids     = [sakuracloud_ssh_key.netbox_key.id]
    disable_pw_auth = true
    note_ids        = [sakuracloud_note.netbox_init.id]
  }
}

# Disk resource
resource "sakuracloud_disk" "netbox" {
  name              = "netbox-disk"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  size              = 40
  plan              = "ssd"
}

