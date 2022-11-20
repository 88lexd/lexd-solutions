######################
# IAM OIDC with GitHub
resource "aws_iam_openid_connect_provider" "github_oidc" {
  # See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws
  url             = var.github_actions_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_oidc_role" {
  name = "api_github_oidc"

  inline_policy {
    name = "allow_github_put_s3_object"
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

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          "Federated" : "${aws_iam_openid_connect_provider.github_oidc.arn}"
        }
        Condition = {
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_source_repo}:*"
          }
        }
      }
    ]
  })
}

###############################################
# Begin IAM user for GitHub CI to upload to S3
# LEGACY - To be removed once OIDC is tested and functional
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