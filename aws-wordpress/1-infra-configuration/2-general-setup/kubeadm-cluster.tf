module "kubeadm_cluster" {
  source = "./kubeadm_cluster"

  jumpbox_sg_id = var.jumpbox_sg_id

  ec2_k8smaster_instance_name = var.ec2_k8smaster_instance_name
  ec2_k8sworker_instance_name = var.ec2_k8sworker_instance_name

  ec2_k8smaster_instance_type = var.ec2_k8smaster_instance_type
  ec2_k8sworker_instance_type = var.ec2_k8sworker_instance_type

  ec2_k8smaster_instance_tags = var.ec2_k8smaster_instance_tags
  ec2_k8sworker_instance_tags = var.ec2_k8sworker_instance_tags

  ec2_keypair_name = var.ec2_keypair_name

  ec2_ami_name     = var.ec2_ami_name
  ec2_ami_owner_id = var.ec2_ami_owner_id

  iam_role_name_for_ec2 = var.iam_role_name_for_ec2

  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  vpc_azs             = var.vpc_azs
  vpc_private_subnets = module.vpc.private_subnets
  vpc_public_subnets  = module.vpc.public_subnets

  cw_log_k8s_dataplane_retention   = var.cw_log_k8s_dataplane_retention
  cw_log_k8s_application_retention = var.cw_log_k8s_application_retention
}
