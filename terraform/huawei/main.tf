terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.60"
    }
  }
  required_version = ">= 1.0"
}

provider "huaweicloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# --- Networking ---

resource "huaweicloud_vpc" "main" {
  name = "${var.project}-vpc"
  cidr = "10.1.0.0/16"
}

resource "huaweicloud_vpc_subnet" "main" {
  name       = "${var.project}-subnet"
  cidr       = "10.1.1.0/24"
  gateway_ip = "10.1.1.1"
  vpc_id     = huaweicloud_vpc.main.id
}

# --- Security Group ---

resource "huaweicloud_networking_secgroup" "vm" {
  name = "${var.project}-sg"
}

resource "huaweicloud_networking_secgroup_rule" "ssh" {
  security_group_id = huaweicloud_networking_secgroup.vm.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "node_exporter" {
  security_group_id = huaweicloud_networking_secgroup.vm.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Key Pair ---

resource "huaweicloud_kps_keypair" "deployer" {
  name       = "${var.project}-key"
  public_key = file(var.ssh_public_key_path)
}

# --- ECS Instance ---

data "huaweicloud_images_image" "ubuntu" {
  name        = "Ubuntu 22.04 server 64bit"
  most_recent = true
}

data "huaweicloud_compute_flavors" "small" {
  availability_zone = "${var.region}a"
  cpu_core_count    = 1
  memory_size       = 1
}

resource "huaweicloud_compute_instance" "vm" {
  name               = "${var.project}-vm"
  image_id           = data.huaweicloud_images_image.ubuntu.id
  flavor_id          = data.huaweicloud_compute_flavors.small.ids[0]
  key_pair           = huaweicloud_kps_keypair.deployer.name
  security_group_ids = [huaweicloud_networking_secgroup.vm.id]
  availability_zone  = "${var.region}a"

  network {
    uuid = huaweicloud_vpc_subnet.main.id
  }

  system_disk_type = "SSD"
  system_disk_size = 10
}

resource "huaweicloud_vpc_eip" "vm" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type  = "PER"
    name        = "${var.project}-bw"
    size        = 5
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "vm" {
  public_ip   = huaweicloud_vpc_eip.vm.address
  instance_id = huaweicloud_compute_instance.vm.id
}
