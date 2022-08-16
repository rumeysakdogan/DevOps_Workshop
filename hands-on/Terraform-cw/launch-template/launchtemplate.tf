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

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }


resource "aws_launch_template" "ec2_launch_template" {
  name                    = "aws_capstone_launch_template"
  description             = "Blog Web Page version 1"
  disable_api_termination = false
  # Need to use interpolation from iam-role module
  iam_instance_profile {
    name = "aws_capstone_EC2_S3_Full_Access"
  }
  image_id      = "ami-0729e439b6769d6ab"
  instance_type = "t2.micro"
  key_name      = "FirstKey"

  # Need to use interpolation from SecGrp module
  #   vpc_security_group_ids = ["sg-12345678"]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "aws_capstone_web_server"
    }
  }
  
    user_data = <<-EOF
          #!/bin/bash
          apt-get update -y
          apt-get install git -y
          apt-get install python3 -y
          cd /home/ubuntu/
          TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          git clone https://$TOKEN@<YOUR PRIVATE REPO URL>
          cd /home/ubuntu/<YOUR PRIVATE REPO NAME>
          apt install python3-pip -y
          apt-get install python3.7-dev default-libmysqlclient-dev -y
          pip3 install -r requirements.txt
          cd /home/ubuntu/<YOUR PRIVATE REPO NAME>/src
          python3 manage.py collectstatic --noinput
          python3 manage.py makemigrations
          python3 manage.py migrate
          python3 manage.py runserver 0.0.0.0:80
          EOF
}