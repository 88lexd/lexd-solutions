data "aws_caller_identity" "current" {}

locals {
  lambda_policy_json = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = ["logs:CreateLogGroup"],
          Resource = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.id}:*"]
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.id}:*:*"]
        },
        {
          Effect = "Allow",
          Action = [
            "ec2:DescribeTags",
            "ec2:CreateTags"
          ],
          Resource = ["*"]
        }
      ]
    }
  )
}
