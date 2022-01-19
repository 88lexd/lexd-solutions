resource "aws_ecr_repository" "jumpbox_uptime" {
  name                 = "jumpbox_uptime"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "jumpbox_uptime_lifecycle_policy" {
  repository = aws_ecr_repository.jumpbox_uptime.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description = "Delete untagged images",
        selection = {
          tagStatus = "untagged"
          countType = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}