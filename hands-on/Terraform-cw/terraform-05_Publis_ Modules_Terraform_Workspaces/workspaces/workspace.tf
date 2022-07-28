terraform {
  # Use your own s3 bucket name and key value
  backend "s3" {
    bucket         = "terraform-state-management-rumeysa-july2022"
    key            = "ec2-docker/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
# creates ec2 based on the workspace that is in deployment using the conditions provided below
resource "aws_instance" "tfmyec2" {
  ami = lookup(var.myami, terraform.workspace)
  instance_type = "${terraform.workspace == "dev" ? "t3a.medium" : "t2.micro"}"
  count = "${terraform.workspace == "prod" ? 3 : 1}"
  key_name = "FirstKey"
  tags = {
    Name = "${terraform.workspace}-server"
  }
}

variable "myami" {
  type = map(string)
  default = { # default var values
    default = "ami-0cff7528ff583bf9a"
    dev     = "ami-06640050dc3f556bb"
    prod    = "ami-08d4ac5b634553e16"
  }
  description = "in order of aAmazon Linux 2 ami, Red Hat Enterprise Linux 8 ami and Ubuntu Server 20.04 LTS amis"
}