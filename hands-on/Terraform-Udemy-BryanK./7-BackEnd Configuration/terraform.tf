terraform {
 required_version = ">= 1.0.0" # Terraform Core version
 backend "local" {
  path = "terraform.tfstate"
 }
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
}