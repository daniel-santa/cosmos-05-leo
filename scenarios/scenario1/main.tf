provider "aws" {
  region = var.region
}

resource "random_pet" "name" {}

resource "aws_vpc" "scenario1" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "scenario1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.scenario1.id

  tags = {
    Name = "scenario1"
  }
}

resource "aws_subnet" "public-sn" {
  vpc_id            = aws_vpc.scenario1.id
  cidr_block        = var.cidr_block_sn
  availability_zone = var.az_sn

  tags = {
    Name = "scenario1"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.scenario1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "scenario1"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.scenario1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "web-sg" {
  # name = "${random_pet.name.id}-sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.scenario1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress Rule for 0.0.0.0/0"
  }

  tags = {
    Name = join("-", [random_pet.name.id, "scenario1", local.env, "sg"])
  }
}

resource "aws_instance" "instance" {
  count = var.count_instances
  ami           = var.ami_id
  instance_type = var.instance_type
  # user_data     = file(var.user_data_name)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = var.key_name_instance

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-sn.id

  tags = {
    Name = join("-", [count.index, local.env])
  }
}
