resource "aws_ecr_repository" "jumpbox_uptime" {
  name                 = "jumpbox_uptime"
  image_tag_mutability = "MUTABLE"
}
