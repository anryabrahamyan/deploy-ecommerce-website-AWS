terraform {
  required_version = "1.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
  #s3 backend not configured to save time during creation
}

provider "aws" {
  region = var.aws_region #TODO move variables to tfvar   
}