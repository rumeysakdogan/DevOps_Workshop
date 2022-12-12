provider "aws" {
  region = "us-east-1"
  #access_key = "ACCESS_KEY"
  #secret_key = "SECRET_KEY"
  # Providing AWS credentials like this is not good practice, either use Env Variables or aws configure.
}

resource "aws_instance" "intro" {
  ami                    = "ami-0b0dcb5067f052a63"
  instance_type          = "t2.micro"
  key_name               = "FirstKey"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = ["sg-017e962f0ed0cae99"]
  tags = {
    Name = "First-Instance"
    Project = "20-days-challenge"
  }
}

