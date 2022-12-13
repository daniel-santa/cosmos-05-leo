provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = join("-", [local.project, local.env, "vpc"])
  cidr = var.cidr_block_vpc

  azs             = [var.az_sn]
  public_subnets  = [var.cidr_block_sn]
  private_subnets = []

  tags = {
    Environment = local.env
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = join("-", [local.project, local.env, "sg"])
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = join("-", [local.project, "instance_profile"])
  role = "ecsInstanceRole"
}

module "ec2_instance" {
  count   = var.count_instances
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = join("-", [local.project, local.env, "instance"])

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name_instance
  monitoring             = false
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = <<-EOF
                            #!/bin/bash
                            echo ECS_CLUSTER=${local.project} >> /etc/ecs/ecs.config
                            EOF
  iam_instance_profile   = resource.aws_iam_instance_profile.instance_profile.name
  tags = {
    Terraform   = "true"
    Environment = local.env
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = local.project

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  default_capacity_provider_use_fargate = false

  tags = {
    Environment = local.env
    Project     = local.project
  }
}

resource "aws_ecs_task_definition" "sleep360" {
  family                = var.family_name_task
  container_definitions = file(var.container_definitions_file)

}
