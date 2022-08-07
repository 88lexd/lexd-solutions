data "aws_caller_identity" "current" {}

data "aws_s3_bucket_object" "lambda_zip" {
  bucket = var.s3_bucket_name
  key    = var.s3_lambda_zip
}

data "aws_instance" "jumpbox" {
  filter {
    name   = "tag:Name"
    values = [var.jumpbox_instance_name]
  }
}

locals {
  lambda_policy_json = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = ["logs:CreateLogGroup"],
          Resource = ["arn:aws:logs:ap-southeast-2:${data.aws_caller_identity.current.id}:*"]
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : ["arn:aws:logs:ap-southeast-2:${data.aws_caller_identity.current.id}:log-group:*:*"]
        },
        {
          Effect   = "Allow",
          Action   = ["ec2:DescribeInstances"],
          Resource = "*"
        },
        {
          Effect   = "Allow",
          Action   = ["ec2:StopInstances"],
          Resource = "arn:aws:ec2:ap-southeast-2:${data.aws_caller_identity.current.id}:instance/${data.aws_instance.jumpbox.id}"
        },
        {
          Effect   = "Allow",
          Action   = ["sns:Publish"],
          Resource = "arn:aws:sns:ap-southeast-2:${data.aws_caller_identity.current.id}:General-Notification-Topic"
        }
      ]
    }
  )
}
