resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_func_name
  description   = var.lambda_func_description
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"

  s3_bucket = "lexd-solutions-lambdas"
  s3_key = "lambda-jumpbox-uptime.zip"

  runtime = "python3.8"

  publish = true

  environment {
    variables = {
      UPTIME_THRESHOLD = "6"
      NOTIFICATION_THRESHOLD = "3"
      SNS_TOPIC_ARN = "arn:aws:sns:ap-southeast-2:682613435495:General-Notification-Topic"
      INSTANCE_ID = "i-0a674f430ae92d9a2"  # Jumpbox
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group,
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_func_name}"
  retention_in_days = var.lambda_cw_logs_retention
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = var.lambda_policy_json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}