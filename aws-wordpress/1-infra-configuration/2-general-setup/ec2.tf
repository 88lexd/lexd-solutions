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

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name = var.ec2_instance_name

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_keypair_name
  vpc_security_group_ids = [aws_security_group.SG_EC2.id]
  subnet_id              = module.vpc.public_subnets[0]
  enable_volume_tags     = true
  volume_tags            = var.ec2_instance_tags
  iam_instance_profile    = aws_iam_instance_profile.ec2_iam_instance_profile.name
  tags = var.ec2_instance_tags
}

# EIP is now attached to kubeadm_cluster's worker node
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = module.ec2_instance.id
#   allocation_id = var.eip_alloc_id
# }

# Let's not create EIP with Terraform as a 'terraform destroy' will remove this production IP with it
# resource "aws_eip" "ec2-eip" {
#   instance = module.ec2_instance.id
#   vpc      = true
#   depends_on = [module.vpc.vpc_id]
#   tags = {
#       Name = var.eip_name_tag
#   }
# }
