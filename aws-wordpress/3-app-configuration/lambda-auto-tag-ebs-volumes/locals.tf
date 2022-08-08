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
          Resource = ["arn:aws:logs:ap-southeast-2:${data.aws_caller_identity.current.id}:log-group:*:*"]
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
