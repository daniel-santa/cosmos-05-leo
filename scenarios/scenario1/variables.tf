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

# variable "user_data_name" {
#   description = "Value of the Name of User Data Script"
#   type        = string
# }

variable "key_name_instance" {
  description = "Name of the key pair"
  type        = string
}

variable "tags" {
  description = "tag value"
  type        = string
  default     = "scenario1"
}

variable "count_instances" {
  description = "Number of instances to deploy"
  type = number
  default = 1
}
