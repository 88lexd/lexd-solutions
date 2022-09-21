data "aws_caller_identity" "current" {}

data "aws_instance" "k8s_master" {
  filter {
    name   = "tag:Name"
    values = [var.ec2_k8smaster_instance_name]
  }
}

data "aws_instance" "k8s_worker" {
  filter {
    name   = "tag:Name"
    values = [var.ec2_k8sworker_instance_name]
  }
}

data "aws_sns_topic" "cw_alarm_topic" {
  name = "CloudWatch-Alarm-Topic"
}

data "archive_file" "codedeploy_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/scripts/codedeploy_lambda.py"
  output_path = "${path.module}/codedeploy_lambda.zip"
}
