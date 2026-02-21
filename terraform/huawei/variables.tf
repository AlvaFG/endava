variable "region" {
  default = "la-south-2" # Santiago, Chile
}

variable "project" {
  default = "endava-demo"
}

variable "access_key" {
  description = "Huawei Cloud Access Key"
  sensitive   = true
}

variable "secret_key" {
  description = "Huawei Cloud Secret Key"
  sensitive   = true
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}
