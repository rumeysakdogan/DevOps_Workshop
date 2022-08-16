terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.24.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach IAM role to AWS EC2 instance using Terraform

#Step 1: Create a policy file
resource "aws_iam_policy" "ec2_policy" {
  name   = "AmazonS3FullAccess"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Step 2: Create a role that can be assumed by an EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "aws_capstone_EC2_S3_Full_Access"

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

# Step 3: Attach the role to the policy file
resource "aws_iam_policy_attachment" "ec2-policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Step 4: Create an instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "aws_capstone_EC2_Profile"
  role = aws_iam_role.ec2_role.name
}

# Step 5: Attach the instance profile to the EC2 instance
resource "aws_instance" "role-test" {
  ami                  = "ami-090fa75af13c156b4"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = "FirstKey"

  tags = {
    Name = "capstone_ec2"
  }
}