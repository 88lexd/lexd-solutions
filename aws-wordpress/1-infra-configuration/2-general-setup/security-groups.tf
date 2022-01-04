resource "aws_security_group" "SG_EC2" {
  name        = "SG-EC2"
  description = "Allow traffic into EC2"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    # My non-static public IP problem: not required to allow SSH to the world anymore.
    # Using this Python script to update SG - https://github.com/88lexd/lexd-solutions/tree/main/misc-scripts/python-aws-update-sg
    # {
    #   description      = "Allow SSH"
    #   from_port        = 22
    #   to_port          = 22
    #   protocol         = "tcp"
    #   cidr_blocks      = ["0.0.0.0/0"]
    #   ipv6_cidr_blocks = null
    #   prefix_list_ids  = null
    #   security_groups  = null
    #   self             = null
    # },
    {
      description      = "Allow HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow NFS"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      self             = true
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
    }
  ]

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

  tags = {
      Name = "Allow traffic into EC2"
  }
}

resource "aws_security_group" "efs_target" {
  name        = "efs-target"
  description = "Allow NFS traffic into EFS"
  vpc_id      = module.vpc.vpc_id

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
      # TO DO: Add the K8s nodes to allow NFS ingress
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
  vpc_id      = module.vpc.vpc_id

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
  vpc_id      = module.vpc.vpc_id

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
  k8s_master_ingress = [
    {
      description  = "Allow SSH from Jumpbox"
      from_port    = 22
      to_port      = 22
      source_sg_id = var.jumpbox_sg_id
    },
    {
      description  = "Access to master kube-apiserver Endpoint"
      from_port    = 6443
      to_port      = 6443
      source_sg_id = aws_security_group.k8s_workernodes.id
    }
  ]

  k8s_worker_ingress = [
    {
      description  = "Allow SSH from Jumpbox"
      from_port    = 22
      to_port      = 22
      source_sg_id = var.jumpbox_sg_id
    },
    {
      description  = "Access to worker kubelet Endpoint"
      from_port    = 10250
      to_port      = 10250
      source_sg_id = aws_security_group.k8s_master.id
    },
    {
      description  = "Access to worker nodeport services"
      from_port    = 30000
      to_port      = 32767
      source_sg_id = aws_security_group.k8s_master.id
    }
  ]
}

resource "aws_security_group_rule" "k8s_master_ingress" {
  count = length(local.k8s_master_ingress)

  type                     = "ingress"
  description              = local.k8s_master_ingress[count.index].description
  from_port                = local.k8s_master_ingress[count.index].from_port
  to_port                  = local.k8s_master_ingress[count.index].to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_master.id
  source_security_group_id = local.k8s_master_ingress[count.index].source_sg_id
}

resource "aws_security_group_rule" "k8s_worker_kubelet_ingress" {
  count = length(local.k8s_worker_ingress)

  type                     = "ingress"
  description              = local.k8s_worker_ingress[count.index].description
  from_port                = local.k8s_worker_ingress[count.index].from_port
  to_port                  = local.k8s_worker_ingress[count.index].to_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_workernodes.id
  source_security_group_id = local.k8s_worker_ingress[count.index].source_sg_id
}
# End Security groups and rules for K8s instances
#################################################
