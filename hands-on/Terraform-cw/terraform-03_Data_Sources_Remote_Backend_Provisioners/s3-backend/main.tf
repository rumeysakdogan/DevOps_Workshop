provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf-remote-state" {
  bucket = "tf-remote-s3-bucket-rumeysa-bdg"
  force_destroy = true # Normally it must be false. Because if we delete s3 mistakenly, we lost all of the states.
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mybackend" {
  bucket = aws_s3_bucket.tf-remote-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_backend_s3" {
  bucket = aws_s3_bucket.tf-remote-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tf-remote-state-lock" {
  hash_key = "LockID"
  name     = "tf-s3-app-lock-rumeysa"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
