terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40.0"
    }
  }

  required_version = ">= 1.3.5"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami                         = "ami-0b0dcb5067f052a63"
  instance_type               = "t2.micro"

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }
  
  tags = {
    Name = var.instance_name
  }
}
