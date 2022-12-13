output "application-url" {
  value = "http://${module.ec2_instance_web.public_ip}/index.html"
}

output "ssh-public-command" {
  value     = "ssh -i <path>/${var.key_name_instance}.pem ec2-user@${module.ec2_instance_web.public_ip}"  
}

output "ssh-private-command" {
  value     = "ssh -i <path>/${var.key_name_instance}.pem ec2-user@${module.ec2_instance_db.private_ip}"  
}

