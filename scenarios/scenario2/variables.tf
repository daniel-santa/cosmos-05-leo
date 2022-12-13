variable "region" {
  description = "Region name"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI Identificator"
  type = string
  default = "ami-0b0dcb5067f052a63"
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t2.micro"
}

variable "key_name_instance" {
  description = "Name of the key pair"
  type        = string
}

variable "cidr_block_vpc" {
    description = "cidr_block_vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "az_sn" {
    description = "az"
    type = string
    default = "us-east-1b"
}

variable "cidr_block_public" {
    description = "cidr_block_public"
    type = string
    default = "10.0.0.0/24"
}

variable "cidr_block_private" {
    description = "cidr_block_private"
    type = string
    default = "10.0.1.0/24"
}

variable "count_instances" {
  description = "Number of instances to deploy"
  type = number
  default = 1
}