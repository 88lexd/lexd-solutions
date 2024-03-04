aws_region = "ap-southeast-2"

s3_bucket_name = "lexd-solutions-lambdas"
s3_lambda_zip  = "lambda-jumpbox-uptime.zip"

jumpbox_instance_name = "Jumpbox"

lambda_environment_variables = {
  # Threshold (int) is in hours
  UPTIME_THRESHOLD       = 12
  NOTIFICATION_THRESHOLD = 3
}

lambda_func_name         = "jumpbox-uptime-notifier"
lambda_func_description  = "Send SNS alert or stop instance is over threshold"
lambda_cw_logs_retention = 7

cw_event_name     = "jumpbox-uptime-cron"
cw_event_schedule = "rate(1 hour)"
