  variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "endava-demo"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "my_ip" {
  description = "Your IP in CIDR notation (e.g. 1.2.3.4/32)"
  default     = "0.0.0.0/0"
}
