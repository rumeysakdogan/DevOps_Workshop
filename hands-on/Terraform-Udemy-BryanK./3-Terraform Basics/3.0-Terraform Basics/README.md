# Understanding Terraform Basics

> [Official Documentation to Get started AWS](https://learn.hashicorp.com/collections/terraform/aws-get-started)

## Lab: Terraform Basics

All interactions with Terraform occur via the CLI. Terraform is a local tool (runs on the current machine). The terraform ecosystem also includes providers for many cloud services, and a module repository. Hashicorp also has products to help teams manage Terraform: Terraform Cloud and Terraform Enter- prise.

>There are a handful of basic terraform commands, including:
 - terraform init
 - terraform validate • terraform plan
 - terraform apply
 - terraform destroy

These commands make up the terraform workflow that we will cover in objective 6 of this course. It will be beneficial for us to explore some basic commands now so that work alongside and deploy our configurations.

- Task1: Verify Terraform installation and version
```bash
terraform -version
```
 If you need to recall a specific subcommand, you can get a list of available commands and arguments
with the help argument.
```bash
terraform -help
```
- Task2: Initialize Terraform Working Directory: 
```bash
terraform init 
```
- Task3: Validating a Configuration: 
```bash
terraform validate
```
- Task4: Genenerating a Terraform Plan:
```bash
terraform plan
```
- Task5: Applying a Terraform Plan:
```bash
terraform apply
```
- Task6: Terraform Destroy:
```bash
terraform destroy
```