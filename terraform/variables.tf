variable "sakuracloud_access_token" {
  description = "Sakura Cloud API access token"
  type        = string
  sensitive   = true
}

variable "sakuracloud_access_token_secret" {
  description = "Sakura Cloud API access token secret"
  type        = string
  sensitive   = true
}

variable "sakuracloud_zone" {
  description = "Sakura Cloud zone (e.g., is1a, is1b, tk1a, tk1v)"
  type        = string
  default     = "is1a"
}

variable "internal_switch_name" {
  description = "Name of the internal switch to connect to"
  type        = string
}

variable "internal_nic_ip" {
  description = "IP address for the internal NIC in CIDR format (e.g., 192.168.1.10/24)"
  type        = string
}
