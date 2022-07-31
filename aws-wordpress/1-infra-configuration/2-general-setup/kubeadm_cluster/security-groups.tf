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
      security_groups  = [var.jumpbox_sg_id, aws_security_group.k8s_master.id, aws_security_group.k8s_workernodes.id]
      self             = null
    }
  ]
}

##############################################
# Security groups and rules for K8s instances
resource "aws_security_group" "k8s_master" {
  name        = "k8s-master"
  description = "Allow traffic into K8s master node"
  vpc_id      = var.vpc_id

  tags = {
      Name = "K8s Master"

  }

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

resource "aws_security_group" "k8s_workernodes" {
  name        = "k8s-workernodes"
  description = "Allow traffic into K8s worker nodes"
  vpc_id      = var.vpc_id

  tags = {
      Name = "K8s Worker"

  }

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

# Must add additional rules seperately to work around the cycle error where both SG depends on each other
# Note: The 'aws_security_group_rule' resource cannot be set multiple times for the same SG
# This method below allow the same resource to contain multiple rules.
locals {
  k8s_master_ingress = {
    allow_ssh_from_jumpbox = {
      description  = "Allow SSH from Jumpbox"
      from_port    = 22
      to_port      = 22
      source_sg_id = var.jumpbox_sg_id
    },
    worker_access_kube_apiserver = {
      description  = "Worker to access to kube-apiserver endpoint"
      from_port    = 6443
      to_port      = 6443
      source_sg_id = aws_security_group.k8s_workernodes.id
    },
    jumpbox_access_kube_apiserver = {
      description  = "Jumpbox to access kube-apiserver endpoint"
      from_port    = 6443
      to_port      = 6443
      source_sg_id = var.jumpbox_sg_id
    },
    worker_access_weavenet = {
      description  = "Access to weavenet"
      from_port    = 6783
      to_port      = 6784
      source_sg_id = aws_security_group.k8s_workernodes.id
    }
  }

  k8s_worker_ingress = {
    allow_ssh_from_jumpbox = {
      description  = "Allow SSH from Jumpbox"
      from_port    = 22
      to_port      = 22
      source_sg_id = var.jumpbox_sg_id
      source_cidrs = null
    },
    master_to_ingress_controller = {
      description  = "Master to access ingress controller service"
      from_port    = 8443
      to_port      = 8443
      source_sg_id = aws_security_group.k8s_master.id
      source_cidrs = null
    },
    master_to_worker_kubelet = {
      description  = "Access to worker kubelet Endpoint"
      from_port    = 10250
      to_port      = 10250
      source_sg_id = aws_security_group.k8s_master.id
      source_cidrs = null
    },
    master_to_worker_nodeports = {
      description  = "Access to worker nodeport services"
      from_port    = 30000
      to_port      = 32767
      source_sg_id = aws_security_group.k8s_master.id
      source_cidrs = null
    },
    master_to_worker_weavenet = {
      description  = "Access to weavenet"
      from_port    = 6783
      to_port      = 6784
      source_sg_id = aws_security_group.k8s_master.id
      source_cidrs = null
    },
    public_http_access = {
      description  = "Allow HTTP traffic to worker nodes"
      from_port    = 80
      to_port      = 80
      source_sg_id = null
      source_cidrs = ["0.0.0.0/0"]
    },
    public_https_access = {
      description  = "Allow HTTPS traffic to worker nodes"
      from_port    = 443
      to_port      = 443
      source_sg_id = null
      source_cidrs = ["0.0.0.0/0"]
    },
    ngrok_nat = {
      description  = "Allow K8s NAT to Ngrok via service and endpoints"
      from_port    = 30000
      to_port      = 30000
      source_sg_id = null
      source_cidrs = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group_rule" "k8s_master_ingress_rules" {
  for_each = local.k8s_master_ingress

  type                     = "ingress"
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_master.id
  source_security_group_id = each.value.source_sg_id
}

resource "aws_security_group_rule" "k8s_worker_kubelet_ingress_rules" {
  for_each = local.k8s_worker_ingress

  type                     = "ingress"
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_workernodes.id
  source_security_group_id = each.value.source_sg_id != null ? each.value.source_sg_id : null
  cidr_blocks              = each.value.source_cidrs != null ? each.value.source_cidrs : null
}
# End Security groups and rules for K8s instances
#################################################
