output "subnet_id_instance" {
  value = module.vpc.public_subnets
}

output "auto_assigned_ips" {
  value = module.ec2_instance.*.public_ip
}