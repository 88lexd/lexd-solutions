terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.66.0"
    }
  }

  backend "s3" {
    bucket = "lexd-solutions-tfstate"
    key    = "terraform/lambda_jumpbox_uptime.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-existing-package-local"
  description   = "My awesome lambda function"

  create_package = false

  image_uri    = "682613435495.dkr.ecr.ap-southeast-2.amazonaws.com/jumpbox_uptime:latest"
  package_type = "Image"

  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    Threshold = 3
  }

  attach_policy_json = true
  policy_json        = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "logs:CreateLogGroup*",
        ]
        Resource = "arn:aws:logs:ap-southeast-2:682613435495:*"
      },
      {
        Effect   = "Allow"
        Action = [
          "*",
        ]
        Resource = "arn:aws:logs:ap-southeast-2:682613435495:log-group:/aws/lambda/test:*"
      }
    ]
  })
}