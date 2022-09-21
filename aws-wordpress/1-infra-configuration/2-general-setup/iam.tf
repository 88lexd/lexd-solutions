###############################################
# Begin IAM user for GitHub CI to upload to S3
resource "aws_iam_user" "github_ci_to_s3" {
  name = "api_github-ci-to-s3"
}

resource "aws_iam_user_policy" "github_ci_to_s3_policy" {
  name = "general-setup-github-ci-to-s3"
  user = aws_iam_user.github_ci_to_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.lambda_s3_bucket.arn}",
          "${aws_s3_bucket.lambda_s3_bucket.arn}/*",
          "${aws_s3_bucket.codedeploy_s3_bucket.arn}",
          "${aws_s3_bucket.codedeploy_s3_bucket.arn}/*"
        ]
      }
    ]
  })
}
# End IAM user for GitHub CI to upload to S3