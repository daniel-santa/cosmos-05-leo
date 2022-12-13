provider "aws" {
  region = var.region
}

resource "random_pet" "name" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = join("-", [local.project,local.env,"vpc"])
  cidr = var.cidr_block_vpc

  azs             = [var.az_sn]
  public_subnets  = [var.cidr_block_public]
  private_subnets = [var.cidr_block_private]

  enable_nat_gateway = true
  tags = {
    Terraform = "true"
  }
}

module "security_group_a" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = join("-", [local.project,local.env,"webserver_sg"])
  description = "Security group for webserver instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

}

module "security_group_b" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = join("-", [local.project,local.env,"dbserver_sg"])
  description = "Security group for dbserver instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["mysql-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

}
module "ec2_instance_web" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = join("-", [local.project,local.env,"webserver"])

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name_instance
  monitoring             = false
  vpc_security_group_ids = [module.security_group_a.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = <<-EOF
                            #!/bin/bash
                            echo "Hello, World" > index.html
                            python3 -m http.server 80 &
                            EOF 
  tags = {
    Terraform   = "true"
    Environment = local.env
  }
}

module "ec2_instance_db" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = join("-", [local.project,local.env,"dbserver"])

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name_instance
  monitoring             = false
  vpc_security_group_ids = [module.security_group_b.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = local.env
  }
}