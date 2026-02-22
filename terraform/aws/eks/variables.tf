variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "endava-demo"
}

variable "cluster_version" {
  default = "1.29"
}

variable "node_instance_type" {
  default = "t3.small"
}

variable "node_desired_size" {
  default = 3
}

variable "node_min_size" {
  default = 1
}

variable "node_max_size" {
  default = 3
}
