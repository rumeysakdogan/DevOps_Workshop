output "hello-world" {
  description = "Print a hello world text output"
  value       = "hello world!"
}

# output "vpc_id" {
#   description = "Output the ID for the primary VPC"
#   value       = aws_vpc.vpc.id
# }

# output "public_ip" {
#   description = "This is the public ip of my web server"
#   value       = aws_instance.web_server.public_ip
# }

# output "ec2_instance_arn" {
#   value       = aws_instance.web_server.arn
#   sensitive = true
# }

output "phone_number" {
  value     = var.phone_number
  sensitive = true
}