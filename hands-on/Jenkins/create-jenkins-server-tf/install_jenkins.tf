//This Terraform Template creates a jenkins server on AWS EC2 Instance
//Jenkins server will run on Amazon Linux 2 with custom security group
//allowing SSH (22) and TCP (8080) connections from anywhere.
//User needs to select appropriate variables from "variable.tf" file when launching the instance.

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

resource "aws_instance" "tf-jenkins-server" {
  ami           = var.myami
  instance_type = var.instancetype
  key_name      = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-jenkins-sec-gr.id]
  user_data = file("install-jenkins.sh")
  tags = {
    Name = var.tags
  }

}

resource "null_resource" "forpasswd" {
  depends_on = [aws_instance.tf-jenkins-server]

  provisioner "local-exec" {
    command = "sleep 180"
  }

  # Do not forget to define your key file path correctly!
  provisioner "local-exec" {
    command = "ssh -i /Users/rumeysadogan/Documents/in-class-docs/${var.mykey}.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@${aws_instance.tf-jenkins-server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > initialpasswd.txt"
  }
}

resource "aws_security_group" "tf-jenkins-sec-gr" {
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

output "jenkins" {
  value = "http://${aws_instance.tf-jenkins-server.public_ip}:8080"
}