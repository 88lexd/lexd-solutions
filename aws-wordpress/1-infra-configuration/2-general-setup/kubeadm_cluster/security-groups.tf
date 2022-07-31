resource "aws_security_group" "efs_target" {
  name        = "efs-target"
  description = "Allow NFS traffic into EFS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "EFS-NFS Target"
  }

  ingress = [
    {
      description      = "Allow HTTP"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      # sg-091d91a3132ebef48 = MicroK8s node! This needs to be removed later
      security_groups = [var.jumpbox_sg_id, aws_security_group.k8s_master.id, aws_security_group.k8s_workernodes.id]
      self            = null
    }
  ]
}

##############################################
# Security groups and rules for K8s instances
resource "aws_security_group" "k8s_master" {
  name        = "k8s-master"
  description = "Allow traffic into K8s master node"
  vpc_id      = var.vpc_id

  tags = { Name = "K8s Master" }

  egress = [local.sg_allow_all_egress]
}

resource "aws_security_group" "k8s_workernodes" {
  name        = "k8s-workernodes"
  description = "Allow traffic into K8s worker nodes"
  vpc_id      = var.vpc_id

  tags = { Name = "K8s Worker" }

  egress = [local.sg_allow_all_egress]
}

# Must add additional rules seperately to work around the cycle error where both SG depends on each other
resource "aws_security_group_rule" "k8s_master_ingress_rules" {
  for_each = local.sg_k8s_master_ingress

  type                     = "ingress"
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_master.id
  source_security_group_id = each.value.source_sg_id
}

resource "aws_security_group_rule" "k8s_worker_kubelet_ingress_rules" {
  for_each = local.sg_k8s_worker_ingress

  type                     = "ingress"
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_workernodes.id
  source_security_group_id = each.value.source_sg_id != null ? each.value.source_sg_id : null
  cidr_blocks              = each.value.source_cidrs != null ? each.value.source_cidrs : null
}
