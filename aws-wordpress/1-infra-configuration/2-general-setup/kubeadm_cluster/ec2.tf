module "ec2_instance" {
  for_each = local.ec2_instances

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name = each.value.name

  ami                     = each.value.ami
  instance_type           = each.value.instance_type
  key_name                = var.ec2_keypair_name
  vpc_security_group_ids  = each.value.security_group_ids
  subnet_id               = each.value.subnet_id
  enable_volume_tags      = true
  volume_tags             = each.value.volume_tags
  iam_instance_profile    = each.value.iam_instance_profile
  disable_api_termination = false
  tags                    = each.value.tags
}

# Not using ELB.. therefore only move EIP manually once new worker node is functional!
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = module.ec2_instance[1].id
#   allocation_id = var.eip_alloc_id
# }
