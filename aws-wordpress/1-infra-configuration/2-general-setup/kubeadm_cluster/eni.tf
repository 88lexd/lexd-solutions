# These are the original ENI's created prior to the code refactoring.
# I needed to retain these IP's and have it reattached to my new instances that is created by my custom AMI

# terraform import module.kubeadm_cluster.aws_network_interface.k8s_master eni-xyz
resource "aws_network_interface" "k8s_master" {
  subnet_id = var.vpc_public_subnets[0]
  security_groups = [aws_security_group.k8s_master.id]
  tags = {
    Name = "k8s_master_eni"
  }
}

# terraform import module.kubeadm_cluster.aws_network_interface.k8s_worker_1 eni-abc
resource "aws_network_interface" "k8s_worker_1" {
  subnet_id       = var.vpc_public_subnets[0]
  security_groups = [aws_security_group.k8s_workernodes.id]

  tags = {
    Name = "k8s_worker_1_eni"
  }
}

