# Setup CodeDeploy to auto release Henry's todo app
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
}


resource "aws_codedeploy_app" "henry_todo_app" {
  name             = "henry-todo-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "henry_todo_deploy_group" {
  app_name              = aws_codedeploy_app.henry_todo_app.name
  deployment_group_name = "henry-todo-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "Name"
      value = var.ec2_k8smaster_instance_name
    }
  }
}


###########################################
# Auto trigger using EventBridge and Lambda
resource "aws_lambda_function" "codedeploy_lambda" {
  function_name = "codedeploy_s3_lambda"

  filename         = data.archive_file.codedeploy_lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.codedeploy_lambda_zip.output_path)

  runtime = "python3.8"
  handler = "codedeploy_lambda.handler"
  timeout = 15

  role = aws_iam_role.codedeploy_lambda_role.arn

  environment {
    variables = {
      APP_NAME          = aws_codedeploy_deployment_group.henry_todo_deploy_group.app_name
      DEPLOY_GROUP_NAME = aws_codedeploy_deployment_group.henry_todo_deploy_group.deployment_group_name
    }
  }
}

resource "aws_lambda_permission" "allow_codedeploy_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.codedeploy_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.codedeploy_s3_bucket.arn
}

resource "aws_cloudwatch_log_group" "codedeploy_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.codedeploy_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "codedeploy_lambda_role" {
  name = "codedeploy_lambda"

  inline_policy {
    name = "allow-create-deployment"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplicationRevision"
          ]
          Effect = "Allow"
          Resource = [
            aws_codedeploy_deployment_group.henry_todo_deploy_group.arn,
            aws_codedeploy_app.henry_todo_app.arn
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "allow-get-deployment-config"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "codedeploy:GetDeploymentConfig"
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }



  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# END Auto trigger using EventBridge and Lambda
