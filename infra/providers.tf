terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
  backend "s3" {
    bucket = "tfstate-alex-cs1"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}