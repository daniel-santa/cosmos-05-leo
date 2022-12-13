provider "aws" {
  region = var.region
}

provider "random" {}
provider "tls" {}

resource "random_pet" "name" {}

#Use of this resource for production deployments is not recommended.
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
key_name = join("-",[var.key_name_prefix,local.env])
  public_key = tls_private_key.rsa-key.public_key_openssh
}
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  user_data     = file(var.user_data_name)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name      = aws_key_pair.generated_key.key_name
  
  # metadata_options {
  #   http_endpoint = "enabled"
  #   http_tokens = "required"
  # } 

  root_block_device {
      encrypted = true
  } 
  
  tags = {
    Name = join("-",[random_pet.name.id,local.env])
  }
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.name.id}-sg"
  description = "Allow inbound HTTP traffic"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"  
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress Rule for 0.0.0.0/0"
  } 
}
