//This Terraform Template creates an EC2 Instance with Java-11 and Maven.
//Amazon Linux 2 (ami-0947d2ba12ee1ff75) will be used as an EC2 Instance with
//custom security group allowing SSH connections from anywhere on port 22.

provider "aws" {
  region = "us-east-1"
  # profile = ""
  //  access_key = ""
  //  secret_key = ""
  //  If you have entered your credentials in AWS CLI before, you do not need to use these arguments.
}

resource "aws_instance" "maven-ec2" {
  ami           = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.micro"
  //  Write your own pem file name
  key_name        = "FirstKey"
  security_groups = ["maven-sec-grp"]

  tags = {
    Name = "Instance of Maven"
  }

  user_data = <<-EOF
                #! /bin/bash
                sudo yum update -y
                sudo yum install java-11-amazon-corretto -y
                cd /home/ec2-user/
                wget https://ftp.itu.edu.tr/Mirror/Apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
                tar -zxvf $(ls | grep apache-maven-*-bin.tar.gz)
                rm -rf $(ls | grep apache-maven-*-bin.tar.gz)
                echo "M2_HOME=/home/ec2-user/$(ls | grep apache-maven)" >> /home/ec2-user/.bash_profile
                echo 'export PATH=$PATH:$M2_HOME/bin' >> /home/ec2-user/.bash_profile
                EOF

}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_security_group" "tf-sec-gr" {
  name   = "maven-sec-grp"
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "maven-sec-grp"
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
