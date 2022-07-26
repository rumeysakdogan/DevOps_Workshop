terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }
  backend "s3" {
    bucket = "tf-remote-s3-bucket-rumeysa-bdg"
    key = "env/dev/tf-remote-backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-s3-app-lock-rumeysa"
    encrypt = true
  }
}

provider "aws" {
  region  = "us-east-1"
}

# data "aws_ami" "tf_ami" {
#   most_recent      = true
#   owners           = ["self"]
#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }
#   filter {
#     name   = "name"
#     values = ["my-ami"]
#   }
# }
resource "aws_instance" "tf-ec2" {
  # ami           = data.aws_ami.tf_ami.id
  ami = var.ec2_ami
  instance_type = var.ec2-type
  key_name      = "FirstKey"
  tags = {
    Name = "${local.mytag}-this is from my-ami"
  }
}

locals {
  mytag = "bdg-local-name"
}
