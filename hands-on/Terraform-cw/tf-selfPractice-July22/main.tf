terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test-ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = "FirstKey"
  tags = {
    "Name" = "created-by-tf"
  }
}

resource "aws_s3_bucket" "test-s3" {
  bucket = "self-practice-s3-rumeysa"
}

# output "test-ec2-public-ip" {
#   value = aws_instance.test-ec2.public_ip
# }

# output "test-ec2-instance-id" {
#     value = aws_instance.test-ec2.id
# }