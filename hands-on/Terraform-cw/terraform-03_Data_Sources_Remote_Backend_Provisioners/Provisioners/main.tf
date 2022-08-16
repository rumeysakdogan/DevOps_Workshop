terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance" {
  ami             = "ami-0c02fb55956c7d316"
  instance_type   = "t2.micro"
  key_name        = "FirstKey"
  security_groups = ["tf-provisioner-sg"]
  tags = {
    Name = "terraform-instance-with-provisioner"
  }
  # Defining a local-exec provisioner
  provisioner "local-exec" {
    command = "echo http://${self.public_ip} > public_ip.txt"
  }
  # Defining remote-exec provisioner
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/FirstKey.pem") # pemKey copied to terraform server 
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }

  provisioner "file" {
    content     = self.public_ip
    destination = "/home/ec2-user/my_public_ip.txt"
  }

}

resource "aws_security_group" "tf-sec-gr" {
  name = "tf-provisioner-sg"
  tags = {
    Name = "tf-provisioner-sg"
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

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
