module "kubeadm_cluster" {
  source              = "./kubeadm_cluster"
  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  vpc_azs             = var.vpc_azs
  vpc_private_subnets = module.vpc.private_subnets
  vpc_public_subnets  = module.vpc.public_subnets
}
