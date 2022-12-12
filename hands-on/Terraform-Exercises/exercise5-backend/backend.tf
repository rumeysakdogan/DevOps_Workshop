terraform {
  backend "s3" {
    bucket = "terra-state-dove-rd"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}