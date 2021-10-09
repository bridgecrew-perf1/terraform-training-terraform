terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51"
    }
  }

  # backend "s3" {
  #   bucket         = "msuslov-tfstate-bucket"
  #   dynamodb_table = "msuslov-tfstate-lock"
  #   key            = "infra-terraform.tfstate"
  #   region         = "eu-central-1"
  #   encrypt        = true
  #   profile        = "terraform-msuslov"
  # }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
