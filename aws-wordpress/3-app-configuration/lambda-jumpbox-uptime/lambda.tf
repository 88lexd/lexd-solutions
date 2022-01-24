###############################################
# Start Lambda function and CloudWatch Trigger
data "aws_s3_bucket_object" "lambda_zip" {
  bucket  = var.s3_bucket_name
  key     = var.s3_lambda_zip
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_func_name
  description   = var.lambda_func_description
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"

  s3_bucket         = data.aws_s3_bucket_object.lambda_zip.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_zip.key
  s3_object_version = data.aws_s3_bucket_object.lambda_zip.version_id

  runtime = "python3.8"

  environment {
    variables = var.lambda_environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attach,
    aws_cloudwatch_log_group.log_group,
  ]
}

resource "aws_cloudwatch_event_rule" "lambda_trigger_event_rule" {
  name = var.cw_event_name
  schedule_expression = var.cw_event_schedule
  depends_on = [ aws_lambda_function.lambda_function ]
}

resource "aws_cloudwatch_event_target" "lambda_trigger_event_target" {
  arn  = aws_lambda_function.lambda_function.arn
  rule = aws_cloudwatch_event_rule.lambda_trigger_event_rule.id
}
# End Lambda function and CloudWatch Trigger

####################################################
# Start Permissions
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_permission" "cloudwatch_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = format("arn:aws:events:ap-southeast-2:682613435495:rule/%s", var.cw_event_name)
}
# End Permissions
