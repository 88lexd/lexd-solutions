# This provides the EC2 instance permissions to do certain actions on AWS (e.g. CloudWatch)
resource "aws_iam_role" "kubeadm_ec2_role" {
  name = var.iam_role_name_for_ec2

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  # This allows the EC2 to assume this IAM role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "codedeploy-s3-access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:GetObject*"
          ]
          Resource = [
            "${var.codedeploy_bucket_arn}",
            "${var.codedeploy_bucket_arn}/*"
          ]
        },
      ]
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

# To link a role to an EC2, an instance profile must be created
resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.kubeadm_ec2_role.name
}
