Terraform Workflow
## Lab: Terraform Workflow 

The core Terraform workflow has three steps:
1. Write-Author infrastructure as code.
2. Plan - Preview changes before applying.
3. Apply - Provision reproducible infrastructure.

The command line interface to Terraform is via the terraform command, which accepts a variety of subcommands such as terraform init or terraform plan. The Terraform command line tool is available for MacOS, FreeBSD, OpenBSD, Windows, Solaris and Linux.

* Task1: Verify Terraform installation
```sh
terraform -version
> Terraform v0.12.6
```
* Task2: Using the Terraform CLI
```sh
terraform -version
terraform -help
```
* Task3: Initializing a Terraform Workspace
```sh
terraform init
```
* Task4: Generating a Terraform Plan
```sh
terraform plan
terraform plan -out myplan
```
* Task5: Applying a Terraform Plan
```sh
terraform apply myplan
```
* Task6: Terraform Destroy
```sh
terraform plan -destroy
terraform destroy
```