variable "jumpbox_sg_id" {
  description = "Security group that is attached to the jumpbox"
  type        = string
}

############################
# BEGIN EC2 Settings
variable "ec2_k8smaster_instance_name" {
  description = "Name for the K8s master instance"
  type        = string
}

variable "ec2_k8sworker_instance_name" {
  description = "Name for the K8s worker instance"
  type        = string
}

variable "ec2_k8smaster_instance_type" {
  description = "Instance type"
  type        = string
}

variable "ec2_k8sworker_instance_type" {
  description = "Instance type"
  type        = string
}

variable "ec2_k8smaster_instance_tags" {
  description = "Tags to attach to the K8s Master instance"
  type        = map(string)
}

variable "ec2_k8sworker_instance_tags" {
  description = "Tags to attach to the K8s Worker instances"
  type        = map(string)
}

variable "ec2_keypair_name" {
  description = "Key Pair name (must already exist!)"
  type        = string
}

variable "ec2_ami_name" {
  description = "Name of the AMI to use (wild card to search all but will use most recent)"
  type        = string
}

variable "ec2_ami_owner_id" {
  description = "Owner ID of the AMI"
  type        = string
}

variable "iam_role_name_for_ec2" {
  description = "The name of the IAM role that is attached to the EC2 instance"
  type        = string
}
# END EC2 Settings


##################
# Additional vars
variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "vpc_azs" {
  description = "List of AZs"
  type = list(string)
}

variable "vpc_private_subnets" {
  description = "List of private subnets"
  type = list(string)
}

variable "vpc_public_subnets" {
  description = "List of public subnets"
  type = list(string)
}

variable "codedeploy_bucket_arn" {
  description = "The ARN of the CodeDeploy S3 bucket. It is used to grant access to the EC2 IAM role"
  type        = string
}
# END Additional vars

###########################
# CloudWatch Log Group vars
variable "cw_log_k8s_dataplane_retention" {
  description = "The number of days to keep the dataplane logs in CloudWatch"
  type        = number
}

variable "cw_log_k8s_application_retention" {
  description = "The number of days to keep the application logs in CloudWatch"
  type        = number
}
# END CloudWatch Log Group vars
