# Lab:Multiple Terraform Providers

Due to the plug-in based architecture of Terraform providers, it is easy to install and utilize multiple providers within the same Terraform configuration. Along with the already configured AWS provider, we will install both the HTTP and Random providers.

- Task1: Install Terraform HTTP provider version
- Task2: Configure Terraform HTTP Provider
- Task3: Install Terraform Random provider version 
- Task4: Configure Terraform Random Provider
- Task5: Install Terraform Local provider version

You can run a `terraform init -upgrade` to validate you pull down the provider versions specified in the configuration and validate with a `terraform version` or a `terraform providers` command.
```sh
 terraform version
Terraform v1.0.8
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.62.0
+ provider registry.terraform.io/hashicorp/http v2.1.0
+ provider registry.terraform.io/hashicorp/random v3.1.0
```
```sh
 terraform providers
Providers required by configuration:
.
|-- provider[registry.terraform.io/hashicorp/http] 2.1.0
|-- provider[registry.terraform.io/hashicorp/random] 3.1.0
|-- provider[registry.terraform.io/hashicorp/aws]
Providers required by state:
provider[registry.terraform.io/hashicorp/aws]
provider[registry.terraform.io/hashicorp/random]
```