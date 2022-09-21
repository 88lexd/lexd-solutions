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
