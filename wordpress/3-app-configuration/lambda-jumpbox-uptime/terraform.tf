terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.66.0"
    }
  }

  backend "s3" {
    bucket = "lexd-solutions-tfstate"
    key    = "terraform/lambda_jumpbox_uptime.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region = var.aws_region
}
