variable "aws_region" {
  description = "AWS region to create these resources"
  type        = string
}

####################################
# Begin VPC Settings
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "AZs to use for this region"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "CIDRs for public subnets"
  type        = list(string)
}
# End VPC Settings


##############################################
# BEGIN Data Lifecycle Manager (DLM) Settings
variable "dlm_schedule_name" {
  description = "Name for the DLM schedule"
  type        = string
}

variable "dlm_schedule_interval" {
  description = "Interval for the schdeule"
  type        = number
  default     = 24
}

variable "dlm_schedule_unit" {
  description = "Unit for the schedule interval"
  type        = string
  default     = "HOURS"
}

variable "dlm_schedule_time" {
  description = "When the policy should be evaluated."
  type        = list(string)
}

variable "dlm_retain_count" {
  description = "Number of snapshots to retain"
  type        = number
  default     = 7
}

variable "dlm_copy_tags" {
  description = "Copy all user-defined tags on a source volume to the snapshot created by DLM"
  type        = bool
  default     = true
}

variable "dlm_tags_to_add" {
  description = "Extra tags to add"
  type = object({
    SnapshotCreator = string
  })
  default = {
    SnapshotCreator = "DLM"
  }
}

variable "dlm_target_tags" {
  description = "Volumes with these tags will be targetted by DLM to take snapshots"
  type = object({
    Snapshot = string
  })
  default = {
    Snapshot = "True"
  }
}
# END Data Lifecycle Manager (DLM) Settings


########################
# Begin S3 buckets
variable "lambda_s3_bucket_name" {
  description = "Name for the S3 bucket to store Lambda zip files. This is where GitHub Actions will drop the archives"
  type        = string
}

variable "codedeploy_s3_bucket_name" {
  description = "Name for the S3 bucket to store codedeploy artifacts. This is where GitHub Actions will drop the archives"
  type        = string
}
# End S3 buckets


#################################
# Vars for kubeadm_cluster module
variable "jumpbox_sg_id" {
  description = "Security group that is attached to the jumpbox"
  type        = string
}

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