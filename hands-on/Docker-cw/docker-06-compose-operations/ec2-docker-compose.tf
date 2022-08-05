//This Terraform Template creates 1 Docker Machines on EC2 Instances
//Docker-compose Machines will run on Amazon Linux 2 with custom security group
//allowing SSH (22) and HTTP (80) connections from anywhere.
//User needs to select appropriate key name when launching the instance.

provider "aws" {
  region = "us-east-1"
  #access_key = ""
  #secret_key = ""
  //  If you have entered your credentials in AWS CLI before, you do not need to use these arguments.
}

resource "aws_instance" "docker-server" {
  ami             = "ami-02e136e904f3da870"
  instance_type   = "t2.micro"
  key_name        = "walter-pem"
  //  Write your pem file name
  vpc_security_group_ids = [aws_security_group.sec-gr.id]
  tags = {
    Name = "docker-compose-instance-1"
  }
  user_data = <<-EOF
              #! /bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              # install docker-compose
              curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
              -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              yum install git -y
              hostnamectl set-hostname "docker-compose-server"
              EOF
}


resource "aws_security_group" "sec-gr" {
    name = "docker-compose-sec-group"
    tags = {
      Name = "docker-compose-sec-group"
    }
    ingress {
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 22
      protocol    = "tcp"
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 5000
      protocol    = "tcp"
      to_port     = 5000
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      protocol    = -1
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
output "docker-compose-public-ip" {
  value = aws_instance.docker-server.public_ip 
}