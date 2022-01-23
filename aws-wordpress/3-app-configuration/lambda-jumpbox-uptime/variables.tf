variable "aws_region" {
  description = "AWS region to create these resources"
  type = string
  default = "ap-southeast-2"
}

#######################
# Lambda Function Vars
variable "s3_bucket_name" {
  description = "The name of the S3 bucket that contains the fuction code"
  type = string
  default = "lexd-solutions-lambdas"
}

variable "s3_lambda_zip" {
  description = "The object (zip) where the Lambda code is stored"
  type = string
  default = "lambda-jumpbox-uptime.zip"
}

variable "lambda_environment_variables" {
  description = "The environmental variables used by the Lambda function"
  type = object({
    UPTIME_THRESHOLD = number
    NOTIFICATION_THRESHOLD = number
    SNS_TOPIC_ARN = string
    INSTANCE_ID = string
  })
  default = {
    UPTIME_THRESHOLD = 12
    NOTIFICATION_THRESHOLD = 6
    SNS_TOPIC_ARN = "arn:aws:sns:ap-southeast-2:682613435495:General-Notification-Topic"
    INSTANCE_ID = "i-0a674f430ae92d9a2"  # Jumpbox
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

variable "lambda_cw_logs_retention" {
  description = "CloudWatch logs retention in days for the Lambda function"
  type = number
  default = 7
}

variable "lambda_policy_json" {
  description = "The JSON policy document for the Lambda function"
  type = string
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup*"
      ],
      "Resource": "arn:aws:logs:ap-southeast-2:682613435495:*"
    },
    {
      "Effect": "Allow",
      "Action": [ "ec2:DescribeInstances" ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [ "ec2:StopInstances" ],
      "Resource": "arn:aws:ec2:ap-southeast-2:682613435495:instance/i-0a674f430ae92d9a2"
    }
  ]
}
EOF
}
# End Lambda Function Vars
