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


############################
# BEGIN EC2 Settings
variable "ec2_instance_name" {
  description = "Name for the EC2 instance"
  type = string
  default = "MasterNode"
}

variable "ec2_instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}

variable "ec2_keypair_name" {
  description = "Key Pair name (must already exist!)"
  type = string
  default = "alex-lexdsolutions"  # This key must already exist! Unfortunately cannot automate this.
}

variable "ec2_ami_name" {
  description = "Name of the AMI to use (wild card to serach all but will use most recent)"
  type = list(string)
  default = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
}

variable "ec2_ami_owner_id" {
  description = "Owner ID of the AMI"
  type = list(string)
  default = ["099720109477"]  # Canonical
}

variable "eip_name_tag" {
  description = "The name tag for the EIP"
  type = string
  default = "EIP for MasterNode"
}
# END EC2 SETTINGS