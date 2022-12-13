terraform {
  backend "s3" {
    bucket = "mytfstate-jdpinedac"
    key    = "testkey"
    dynamodb_table = "mytfstate-table-jdpinedac"
    region = "us-east-1"
  }
}
