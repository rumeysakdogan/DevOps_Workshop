terraform {
  required_version = ">= 1.0.0"
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

data "aws_ami" "amazon-linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

data "aws_vpc" "selected" {
  default = true
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "apache-instance-ports" {
  type        = list(number)
  description = "apache-instance-sec-gr-inbound-rules"
  default     = [22, 80]
}


resource "aws_instance" "ec2_instance" {
  count                  = 2
  ami                    = data.aws_ami.amazon-linux2.id
  instance_type          = var.instance_type
  key_name               = "FirstKey"
  vpc_security_group_ids = [aws_security_group.apache-sec-grp.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              chmod -R 777 /var/www/html/
              cd /var/www/html/
              echo 'Hello World! This server deployed by Rumeysa using Terraform' > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
	            EOF

  provisioner "local-exec" {
    command = "echo http://${self.public_ip} >> public.txt"
  }

  provisioner "local-exec" {
    command = "echo http://${self.private_ip} >> private.txt"
  }

  # connection {
  #   host        = self.public_ip
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   private_key = file("/Users/rumeysadogan/IdeaProjects/DevOps_Workshop/coding-challenges/cc-002-create-resources-on-aws/FirstKey.pem") # pemKey copied to terraform server 
  # }

  # provisioner "file" {
  #   content     = self.associate_public_ip_address
  #   destination = "/home/ec2-user/public_ip.txt"
  # }

  tags = {
    Name = "Terraform-${count.index}-Instance"
  }
}

resource "aws_security_group" "apache-sec-grp" {
  name        = "allow_ssh_hhtp"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.apache-instance-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "apache-sec-grp"
  }
}

output "myec2-public-ip" {
  value = aws_instance.ec2_instance.*.public_ip
}
