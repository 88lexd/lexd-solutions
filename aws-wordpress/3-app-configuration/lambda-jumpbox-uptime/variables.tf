variable "aws_region" {
  description = "AWS region to create these resources"
  type        = string
  default     = "ap-southeast-2"
}

############################
# Start Lambda Function Vars
variable "s3_bucket_name" {
  description = "The name of the S3 bucket that contains the fuction code"
  type        = string
  default     = "lexd-solutions-lambdas"
}

variable "s3_lambda_zip" {
  description = "The object (zip) where the Lambda code is stored"
  type        = string
  default     = "lambda-jumpbox-uptime.zip"
}

variable "jumpbox_instance_name" {
  description = "The name tag of the jumpbox instance"
  type = string
  default = "Jumpbox"
}

variable "lambda_environment_variables" {
  description = "The environmental variables used by the Lambda function"
  type = object({
    UPTIME_THRESHOLD       = number
    NOTIFICATION_THRESHOLD = number
  })
  default = {
    # Threshold (int) is in hours
    UPTIME_THRESHOLD       = 12
    NOTIFICATION_THRESHOLD = 3
  }
}

variable "lambda_func_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "jumpbox-uptime-notifier"
}

variable "lambda_func_description" {
  description = "Description for the Lambda function"
  type        = string
  default     = "Send SNS alert or stop instance is over threshold"
}

variable "lambda_cw_logs_retention" {
  description = "CloudWatch logs retention in days for the Lambda function"
  type        = number
  default     = 7
}
# End Lambda Function Vars

####################################
# Start CloudWatch/EventBridge Vars
variable "cw_event_name" {
  description = "The name for the CloudWatch/EventBridge name (name is used in the lambda_policy_json)"
  type        = string
  default     = "jumpbox-uptime-cron"
}

variable "cw_event_schedule" {
  description = "The cron schedule for the CW event"
  type        = string
  default     = "rate(1 hour)"
}
# End CloudWatch/EventBridge Vars
