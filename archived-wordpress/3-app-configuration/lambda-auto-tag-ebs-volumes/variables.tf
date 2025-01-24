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
  default     = "lambda-auto-tag-ebs-volumes.zip"
}

variable "lambda_func_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "auto-tag-ebs-volumes"
}

variable "lambda_func_description" {
  description = "Description for the Lambda function"
  type        = string
  default     = "Auto tag EBS volume by using attached instance tags"
}

variable "lambda_iam_role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
  default     = "iam_auto_tag_ebs_lambda"
}

variable "lambda_iam_policy_name" {
  description = "The name of the IAM policy for the Lambda function"
  type        = string
  default     = "iam_auto_tag_ebs_policy"
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
  description = "The name for the CloudWatch/EventBridge"
  type        = string
  default     = "lambda-auto-tag-ebs-on-attach"
}

variable "cw_event_schedule" {
  description = "The cron schedule for the CW event"
  type        = string
  default     = "rate(1 hour)"
}
# End CloudWatch/EventBridge Vars
