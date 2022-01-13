data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ec2_ami_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = var.ec2_ami_owner_id
}

# locals will define the instance details for the ec2_instance module
locals {
  ec2_instances = {
      k8s_master = {
        name  = var.ec2_k8smaster_instance_name
        ami    = data.aws_ami.ubuntu.id
        instance_type = var.ec2_k8smaster_instance_type
        security_group_ids = [aws_security_group.k8s_master.id]
        subnet_id = var.vpc_public_subnets[0]
        volume_tags = var.ec2_k8smaster_instance_tags
        iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name
        tags = var.ec2_k8smaster_instance_tags
      }

      k8s_worker1 = {
        name  = var.ec2_k8sworker_instance_name
        ami    = data.aws_ami.ubuntu.id
        instance_type = var.ec2_k8sworker_instance_type
        security_group_ids = [aws_security_group.k8s_workernodes.id]
        subnet_id = var.vpc_public_subnets[0]
        volume_tags = var.ec2_k8sworker_instance_tags
        iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.name
        tags = var.ec2_k8sworker_instance_tags
      }
  }
}

module "ec2_instance" {
  for_each = local.ec2_instances

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name = each.value.name

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  key_name               = var.ec2_keypair_name
  vpc_security_group_ids = each.value.security_group_ids
  subnet_id              = each.value.subnet_id
  enable_volume_tags     = true
  volume_tags            = each.value.volume_tags
  iam_instance_profile    = each.value.iam_instance_profile
  disable_api_termination = false
  tags = each.value.tags
}

# Not using ELB.. therefore only move EIP manually once new worker node is functional!
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = module.ec2_instance[1].id
#   allocation_id = var.eip_alloc_id
# }