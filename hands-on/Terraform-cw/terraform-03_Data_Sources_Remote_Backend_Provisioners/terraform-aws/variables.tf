variable "ec2-type" {
  default = "t2.micro"
  type = string
  description = "ec2 type"
}

variable "ec2_ami" {
}

variable "ec2_name" {
}

variable "num_of_buckets" {
  default = 0
}

variable "users" {
}

variable "s3_bucket_name" {
  default = "dev-bucket-rumeysa"
}