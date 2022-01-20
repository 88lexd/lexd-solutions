variable "aws_region" {
  description = "AWS region to create these resources"
  type = string
  default = "ap-southeast-2"
}

#######################
# Lambda Function Vars
variable "lambda_environment_variables" {
  description = "The environmental variables used by the Lambda function"
  type = object({
    NOTIFICATION_THRESHOLD_HOURS = number
    STOP_INSTANCE_THRESHOLD_HOURS = number
  })
  default = {
    NOTIFICATION_THRESHOLD_HOURS = 2
    STOP_INSTANCE_THRESHOLD_HOURS = 6
  }
}

variable "lambda_func_name" {
  description = "Name of the Lambda function"
  type = string
  default = "jumpbox-uptime-notifier"
}

variable "lambda_func_description" {
  description = "Description for the Lambda function"
  type = string
  default = "Send SNS alert or stop instance is over threshold"
}

variable "lambda_ecr_image_uri" {
  description = "The container URI that is stored in ECR"
  type = string
  default = "682613435495.dkr.ecr.ap-southeast-2.amazonaws.com/jumpbox_uptime:latest"
}

variable "lambda_cw_logs_retention" {
  description = "CloudWatch logs retention in days for the Lambda function"
  type = number
  default = 7
}

variable "lambda_policy_json" {
  description = "The JSON policy document for the Lambda function"
  type = object({
    Version = string
    Statement = any
  })
  default = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup*",
        ]
        Resource = "arn:aws:logs:ap-southeast-2:682613435495:*"
      },
      {
        Effect = "Allow"
        Action = [
          "*",
        ]
        Resource = "arn:aws:logs:ap-southeast-2:682613435495:log-group:/aws/lambda/test:*"
      }
    ]
  }
}
# End Lambda Function Vars