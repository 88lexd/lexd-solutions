resource "aws_efs_file_system" "k8s_efs" {
  availability_zone_name = var.vpc_azs[0]  # ap-southeast-2a is the first zone in the list()

  tags = {
    Name = "EFS for K8s"
  }
}

resource "aws_efs_mount_target" "k8s_efs_target" {
  file_system_id = aws_efs_file_system.k8s_efs.id
  subnet_id = var.vpc_private_subnets[0]
  security_groups = [aws_security_group.efs_target.id]
}
