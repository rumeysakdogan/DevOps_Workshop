provider "aws" {
  region  = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
}

resource "aws_instance" "tf-ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  key_name      = "FirstKey"    # write your pem file without .pem extension>
  tags = {
    "Name" = "${local.mytag}-come from locals"
  }
}

resource "aws_instance" "tf-ec2-second" {
  ami           = aws_instance.tf-ec2.ami
  instance_type = "t2.micro"
  key_name      = "FirstKey"    # write your pem file without .pem extension>
  tags = {
    "Name" = "${local.mytag}-come from locals"
  }
}

resource "aws_s3_bucket" "tf-s3-indexed" {
 bucket = "${var.s3_bucket_name}-${count.index}"
# count = var.num_of_buckets
count = var.num_of_buckets != 0 ? var.num_of_buckets : 3
}

resource "aws_s3_bucket" "tf-s3-for-each-case" {
  # bucket = "var.s3_bucket_name.${count.index}"
  # count = var.num_of_buckets
  # count = var.num_of_buckets != 0 ? var.num_of_buckets : 1
  for_each = toset(var.users)
  bucket   = "rumeysa-tf-s3-bucket-${each.value}"
}

output "tf_example_public_ip" {
  value = aws_instance.tf-ec2.public_ip
}

#output "tf_example_s3_meta" {
#  value = aws_s3_bucket.tf-s3-indexed[count.index].region
#}

locals {
  mytag = "oliver-local-name"
}
