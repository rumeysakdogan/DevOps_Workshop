# I like this approach better
# less step to attach policy to role

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

# Creating IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "aws_capstone_EC2_S3_Full_Access"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })


}

# Creating an instance profile to attach IAM role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "aws_capstone_EC2_Profile"
  role = aws_iam_role.ec2_role.name
}

# Create s3FullAccess Policy and attaching to ec2_role
resource "aws_iam_role_policy" "ec2_policy" {
  name = "AmazonS3FullAccess"
  role = aws_iam_role.ec2_role.id

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

#Create an EC2 instance and attach aws_capstone_EC2_S3_Full_Access role to EC2
resource "aws_instance" "role-test" {
  ami                  = "ami-090fa75af13c156b4"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = "FirstKey"
  user_data            = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        cd /var/www/html
        aws s3 cp s3://ec2-s3-test-rumeysa/index.html .
        aws s3 cp s3://ec2-s3-test-rumeysa/cat.jpg .
        systemctl enable httpd
        systemctl start httpd
  EOF
  tags = {
    Name = "capstone_ec2"
  }
}