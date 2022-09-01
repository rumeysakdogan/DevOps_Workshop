//This Terraform Template creates 3 Ansible Machines on EC2 Instances
//Ansible Machines will run on Red Hat Enterprise Linux 8 with custom security group
//allowing SSH (22), HTTP (80) and 3306 connections from anywhere.
//User needs to select appropriate variables form "tfvars" file when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
#  secret_key = ""
#  access_key = ""
}

resource "aws_instance" "nodes" {
  ami = var.myami
  instance_type = var.instancetype
  count = var.num
  key_name = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = element(var.tags, count.index)
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = var.mysecgr
  tags = {
    Name = var.mysecgr
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
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "config" {
  depends_on = [aws_instance.nodes[0]]
  connection {
    host = aws_instance.nodes[0].public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("/Users/rumeysadogan/Documents/in-class-docs/${var.mykey}.pem")
    # Do not forget to define your key file path correctly!
  }

  provisioner "file" {
    source = "./ansible.cfg"
    destination = "/home/ec2-user/ansible.cfg"
  }

  provisioner "file" {
    # Do not forget to define your key file path correctly!
    source = "/Users/rumeysadogan/Documents/in-class-docs/${var.mykey}.pem"
    destination = "/home/ec2-user/${var.mykey}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo yum install -y python3",
      "pip3 install --user ansible",
      "echo [servers] > inventory.txt",
      "echo db_server ansible_host=${aws_instance.nodes[1].private_ip} ansible_ssh_private_key_file=~/${var.mykey}.pem  ansible_user=ec2-user >> inventory.txt",
      "echo web_server ansible_host=${aws_instance.nodes[2].private_ip} ansible_ssh_private_key_file=~/${var.mykey}.pem  ansible_user=ec2-user >> inventory.txt",
      "chmod 400 ${var.mykey}.pem"
    ]
  }

}

output "controlnodeip" {
  value = aws_instance.nodes[0].public_ip
}

output "privates" {
  value = aws_instance.nodes.*.private_ip
}
