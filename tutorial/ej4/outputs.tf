output "domain-name" {
  value = aws_instance.web.public_dns
}

output "application-url" {
  value = "http://${aws_instance.web.public_dns}/index.php"
}

output "private_key" {
  value     = tls_private_key.rsa-key.private_key_pem
  sensitive = true
}

output "ssh-command" {
  value     = "terraform output -raw private_key > archivo.pem; chmod 400 archivo.pem; ssh -i archivo.pem ec2-user@${aws_instance.web.public_ip}"  
}