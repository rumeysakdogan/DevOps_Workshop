output "data-bucket-arn" {
value = data.aws_s3_bucket.data_bucket.arn
}
output "data-bucket-domain-name" {
  value = data.aws_s3_bucket.data_bucket.bucket_domain_name
}
output "data-bucket-region" {
  value = "The ${data.aws_s3_bucket.data_bucket.id} bucket is located in ${data.aws_s3_bucket.data_bucket.region}"
}