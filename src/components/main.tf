terraform {
  required_version = ">= 1.6.2"

  backend "s3" {
    region         = "eu-west-1"
    dynamodb_table = "terraform"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}