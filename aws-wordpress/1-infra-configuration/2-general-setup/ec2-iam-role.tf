# This provides the EC2 instance permissions to do certain actions on AWS (e.g. CloudWatch)

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

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

  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

# To link a role to an EC2, an instance profile must be created
resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  role = aws_iam_role.ec2_role.name
}

# Additional policy to give full S3 access. Not in used now but can be used as reference later on
# resource "aws_iam_role_policy" "ec2_iam_policy" {
#   name = "ec2_iam_policy"
#   role = aws_iam_role.ec2_role.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": [
#           "s3:*"
#         ],
#         "Effect": "Allow",
#         "Resource": "*"
#       }
#     ]
#   })
# }