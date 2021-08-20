terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
