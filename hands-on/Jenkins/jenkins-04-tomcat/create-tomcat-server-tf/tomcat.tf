//This Terraform config file creates 2 Tomcat Server (Stage and Production) on EC2 Instance. Applicable in N. Virginia(us-east-1).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "tomcat-server" {
  ami           = var.myami
  instance_type = var.instancetype
  key_name      = var.mykey
  count = 2
  vpc_security_group_ids = [aws_security_group.tf-tomcat-sec-gr.id]
  user_data = file("userdata.sh")
  tags = {
    Name = "tomcat-${element(var.tags, count.index)}"
  }

}

resource "aws_security_group" "tf-tomcat-sec-gr" {
  name = var.secgrname
  tags = {
    Name = var.secgrname
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "tomcatserverspublicip" {
  value = aws_instance.tomcat-server.*.public_dns
}
