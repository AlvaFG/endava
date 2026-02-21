variable "location" {
  default = "eastus2"
}

variable "project" {
  default = "endava-demo"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/azure_rsa.pub"
}

variable "my_ip" {
  description = "Your IP in CIDR notation (e.g. 1.2.3.4/32)"
  default     = "*"
}
