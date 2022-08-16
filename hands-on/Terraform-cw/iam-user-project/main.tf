module "usermodule" {
  source = "./modules"
  environment = "DEV"
}

output "my-tf-iam-user" {
  value = module.usermodule.my-terraform-user
}