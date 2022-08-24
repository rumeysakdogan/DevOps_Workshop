resource "aws_vpc" "vpc" {
  region = "us-east-1"
  cidr_block = "10.0.0.0/16"
tags = {
  Environment = "demo_environment"
  Terraform   = "true"
}
}