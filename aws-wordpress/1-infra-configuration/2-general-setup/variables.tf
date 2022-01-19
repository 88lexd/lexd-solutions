variable "aws_region" {
  description = "AWS region to create these resources"
  type = string
  default = "ap-southeast-2"
}

####################################
# Begin VPC Settings
variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "LEXD-VPC"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "AZs to use for this region"
  type = list(string)
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "vpc_private_subnets" {
  description = "CIDRs for private subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  description = "CIDRs for public subnets"
  type = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}
# End VPC Settings


##############################################
# BEGIN Data Lifecycle Manager (DLM) Settings
variable "dlm_schedule_name" {
  description = "Name for the DLM schedule"
  type = string
  default = "Daily snapshots"
}

variable "dlm_schedule_interval" {
  description = "Interval for the schdeule"
  type = number
  default = 24
}

variable "dlm_schedule_unit" {
  description = "Unit for the schedule interval"
  type = string
  default = "HOURS"
}

variable "dlm_schedule_time" {
  description = "When the policy should be evaluated."
  type = list(string)
  default = ["16:30"]  # 24 hour clock in UTC (equivalent to 2AM in Sydney)
}

variable "dlm_retain_count" {
  description = "Number of snapshots to retain"
  type = number
  default = 7
}

variable "dlm_copy_tags" {
  description = "Copy all user-defined tags on a source volume to the snapshot created by DLM"
  type = bool
  default = true
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
# Begin Lambda Function
variable "lambda_s3_bucket_name" {
  description = "Name for the S3 bucket to store Lambda zip files. This is where GitHub Actions will drop the archives"
  type = string
  default = "lexd-solutions-lambdas"
}

# End Lambda Function