terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }

  backend "s3" {
    bucket = "mytfstate-jdpinedac-oregon"
    key    = "examples/ex4"
    dynamodb_table = "mytfstate-table-jdpinedac"
    region = "us-west-2"
  }

  required_version = "~> 1.3.5"
}
