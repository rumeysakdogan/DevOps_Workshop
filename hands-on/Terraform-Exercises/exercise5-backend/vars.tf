variable "REGION" {
  default = "us-east-1"
}

variable "ZONE" {
  default = "us-east-1a"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-1 = "ami-0b0dcb5067f052a63"
    us-east-2 = "ami-0beaa649c482330f7"
  }
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "USER" {
  default = "ec2-user"
}