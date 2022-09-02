//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {}
variable "mykey" {}
variable "mykeypem" {}
variable "tags" {}
variable "myami" {
  description = "in order of; amazon linux 2, redhat enterprise linux 8, ubuntu 20.04"
}
variable "instancetype" {}
variable "num" {}
variable "mysecgr" {}