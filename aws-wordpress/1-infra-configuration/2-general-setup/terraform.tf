terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.58.0"
    }
  }

  backend "s3" {
    bucket         = "lexd-solutions-tfstate"
    key            = "terraform/tfstate"
    dynamodb_table = "lexd-solutions-tflockstate"
    region         = "ap-southeast-2"
  }
}

provider "aws" {
  region = var.aws_region
}
