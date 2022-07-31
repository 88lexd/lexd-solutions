# locals will define the instance details for the ec2_instance module
locals {
  ############
  # Instances
  ec2_instances = {
    k8s_master = {
      name                 = var.ec2_k8smaster_instance_name
      ami                  = data.aws_ami.ubuntu.id
      instance_type        = var.ec2_k8smaster_instance_type
      security_group_ids   = [aws_security_group.k8s_master.id]
      subnet_id            = var.vpc_public_subnets[0]
      volume_tags          = merge(var.ec2_k8smaster_instance_tags)
      iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name
      tags                 = merge(var.ec2_k8smaster_instance_tags)
    }

    k8s_worker1 = {
      name                 = var.ec2_k8sworker_instance_name
      ami                  = data.aws_ami.ubuntu.id
      instance_type        = var.ec2_k8sworker_instance_type
      security_group_ids   = [aws_security_group.k8s_workernodes.id]
      subnet_id            = var.vpc_public_subnets[0]
      volume_tags          = merge(var.ec2_k8sworker_instance_tags)
      iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name
      tags                 = merge(var.ec2_k8sworker_instance_tags)
    }
  }

  ########################
  # Security Groups Rules
  sg_allow_all_egress = {
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

  sg_k8s_master_ingress = {
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

  sg_k8s_worker_ingress = {
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
