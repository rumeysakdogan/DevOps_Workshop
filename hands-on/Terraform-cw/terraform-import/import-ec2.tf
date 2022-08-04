provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "example-ec2" {
  ami           = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"
  key_name      = "FirstKey"
  //  Write your pem file name
 vpc_security_group_ids = ["vpc-0283d2568c5c3d6f6"]
  subnet_id = "subnet-06bb8a795a2c33ca9"
  tags = {
    Name = "learn-tf-import"
  }
}
