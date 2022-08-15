resource "random_pet" "server" {
  length = 2
}

module "s3-bucket_example_complete" {
  source  = "terraform-aws-modules/s3-bucket/aws//examples/complete"
  version = "2.10.0"
}