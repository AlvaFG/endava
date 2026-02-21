output "public_ip" {
  value = huaweicloud_vpc_eip.vm.address
}

output "instance_id" {
  value = huaweicloud_compute_instance.vm.id
}
