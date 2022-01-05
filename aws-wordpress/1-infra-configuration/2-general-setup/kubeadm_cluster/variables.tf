variable "jumpbox_sg_id" {
  description = "Security group that is attached to the jumpbox"
  type = string
  default = "sg-0db47122b8885fb8d"
}

############################
# BEGIN EC2 Settings
variable "ec2_k8smaster_instance_name" {
  description = "Name for the K8s master instance"
  type = string
  default = "K8s Master"
}

variable "ec2_k8sworker_instance_name" {
  description = "Name for the K8s worker instance"
  type = string
  default = "K8s Worker"
}

variable "ec2_k8smaster_instance_type" {
  description = "Instance type"
  type = string
  default = "t3a.small"
}

variable "ec2_k8sworker_instance_type" {
  description = "Instance type"
  type = string
  default = "t3a.small"
}

variable "ec2_k8smaster_instance_tags" {
  description = "Tags to attach to the K8s Master instance"
  type = object({
    Snapshot = string
  })
  default = {
    Snapshot = "True"
  }
}

variable "ec2_k8sworker_instance_tags" {
  description = "Tags to attach to the K8s Worker instances"
  type = object({
    Snapshot = string
  })
  default = {
    Snapshot = "False"
  }
}

variable "ec2_keypair_name" {
  description = "Key Pair name (must already exist!)"
  type = string
  default = "alex-lexdsolutions"  # This key must already exist! Unfortunately cannot automate this.
}

variable "ec2_ami_name" {
  description = "Name of the AMI to use (wild card to search all but will use most recent)"
  type = list(string)
  default = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210907"]
}

variable "ec2_ami_owner_id" {
  description = "Owner ID of the AMI"
  type = list(string)
  default = ["099720109477"]  # Canonical
}

variable "iam_role_name_for_ec2" {
  description = "The name of the IAM role that is attached to the EC2 instance"
  type = string
  default = "kubeadm_ec2_role"
}
# END EC2 Settings

##############################################
# Additional vars that's pass into this module
variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}
