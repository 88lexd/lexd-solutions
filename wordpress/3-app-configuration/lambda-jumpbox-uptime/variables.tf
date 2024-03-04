variable "aws_region" {
  description = "AWS region to create these resources"
  type        = string
}

############################
# Start Lambda Function Vars
variable "s3_bucket_name" {
  description = "The name of the S3 bucket that contains the fuction code"
  type        = string
}

variable "s3_lambda_zip" {
  description = "The object (zip) where the Lambda code is stored"
  type        = string
}

variable "jumpbox_instance_name" {
  description = "The name tag of the jumpbox instance"
  type        = string
}

variable "lambda_environment_variables" {
  description = "The environmental variables used by the Lambda function. Threshold is in hours"
  type = object({
    UPTIME_THRESHOLD       = number
    NOTIFICATION_THRESHOLD = number
  })
}

variable "lambda_func_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_func_description" {
  description = "Description for the Lambda function"
  type        = string
}

variable "lambda_cw_logs_retention" {
  description = "CloudWatch logs retention in days for the Lambda function"
  type        = number
}
# End Lambda Function Vars

####################################
# Start CloudWatch/EventBridge Vars
variable "cw_event_name" {
  description = "The name for the CloudWatch/EventBridge name (name is used in the lambda_policy_json)"
  type        = string
}

variable "cw_event_schedule" {
  description = "The cron schedule for the CW event"
  type        = string
}
# End CloudWatch/EventBridge Vars
