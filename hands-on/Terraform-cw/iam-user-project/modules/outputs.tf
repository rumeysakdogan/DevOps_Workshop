# outputs.tf

output "my-terraform-user" {
  value = aws_iam_user.my-new-user.name
}