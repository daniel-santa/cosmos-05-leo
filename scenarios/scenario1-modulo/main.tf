provider "aws" {
  region = var.region
}

resource "random_pet" "name" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = join("-", ["scenario1", "vpc"])
  cidr = var.cidr_block_vpc

  azs             = [var.az_sn]
  public_subnets  = [var.cidr_block_sn]
  private_subnets = []

  tags = {
    Terraform = "true"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = join("-", [random_pet.name.id, "scenario1", local.env, "sg"])
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

}

module "ec2_instance" {
  count = var.count_instances
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = join("-", [count.index, local.env])

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name_instance
  monitoring             = false
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = <<-EOF
                            #!/bin/bash
                            echo "Hello, World" > index.html
                            python3 -m http.server 80 &
                            EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}