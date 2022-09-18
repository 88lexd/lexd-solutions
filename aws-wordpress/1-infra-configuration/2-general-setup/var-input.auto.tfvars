aws_region          = "ap-southeast-2"
vpc_name            = "LEXD-VPC"
vpc_cidr            = "10.0.0.0/16"
vpc_azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_public_subnets  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]

dlm_schedule_name     = "Daily snapshots"
dlm_schedule_interval = 24
dlm_schedule_unit     = "HOURS"
dlm_schedule_time     = ["16:30"] # 24 hour clock in UTC (equivalent to 2AM in Sydney)
dlm_retain_count      = 7
dlm_copy_tags         = true

lambda_s3_bucket_name     = "lexd-solutions-lambdas"
codedeploy_s3_bucket_name = "lexd-solutions-codedeploy"

##############
# K8s Cluster
jumpbox_sg_id = "sg-0db47122b8885fb8d"

ec2_k8smaster_instance_name = "K8s Master"
ec2_k8sworker_instance_name = "K8s Worker"

ec2_k8smaster_instance_type = "t3a.small"
ec2_k8sworker_instance_type = "t3a.small"

ec2_k8smaster_instance_tags = {
  K8s_Role = "Master"
  Snapshot = "True"
}

ec2_k8sworker_instance_tags = {
  K8s_Role = "Worker"
  Snapshot = "True"
}

# This key must already exist! Unfortunately cannot automate this.
ec2_keypair_name = "alex-lexdsolutions"

ec2_ami_name     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210907"
ec2_ami_owner_id = "099720109477" # Canonical

iam_role_name_for_ec2 = "kubeadm_ec2_role"

# CloudWatch log retention period (in days)
cw_log_k8s_dataplane_retention   = 7
cw_log_k8s_application_retention = 14