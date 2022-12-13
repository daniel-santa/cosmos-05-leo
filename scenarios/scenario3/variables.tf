variable "region" {
  description = "Region name"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI Identificator"
  type = string
  default = "ami-0fe5f366c083f59ca"
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t2.micro"
}

variable "cidr_block_vpc" {
    description = "cidr_block_vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "cidr_block_sn" {
    description = "cidr_block_sn"
    type = string
    default = "10.0.0.0/24"
}

variable "az_sn" {
    description = "az"
    type = string
    default = "us-east-1a"
}

variable "count_instances" {
  description = "Number of instances to deploy"
  type = number
  default = 1
}

variable "container_name" {
  description = "name of container"
  type = string
}

variable "container_definitions_file" {
  description = "name of container definitions"
  type = string
}

variable "key_name_instance" {
  description = "Name of the key pair"
  type        = string
}

variable "family_name_task" {
  description = "Name of the key pair"
  type        = string
}