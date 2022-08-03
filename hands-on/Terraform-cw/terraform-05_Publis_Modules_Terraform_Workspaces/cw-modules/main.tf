provider "aws" {
  region = "us-east-1"
}

module "docker-instance" {
  source  = "rumeysakdogan/docker-instance/aws"
  version = "0.0.1"
  key_name = "FirstKey"
  tags = {
    Name = "docker-server"
  }
}