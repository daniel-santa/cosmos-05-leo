variable "region" {
  description = "Region name"
  type = string
}

variable "ami_id" {
  description = "AMI Identificator"
  type = string
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t2.micro"
}

variable "user_data_name" {
  description = "Value of the Name of User Data Script"
  type        = string
}

variable "key_name_prefix" {
  description = "Name of the key pair"
  type        = string
  default     = "rsa-key"
}