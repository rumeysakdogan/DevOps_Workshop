terraform {
  # backend "remote" {
  #   organization = "rumeysadgn"
  #   workspaces {
  #     name = "my-aws-app"
  #   }
  # }
  required_version = "~> 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}