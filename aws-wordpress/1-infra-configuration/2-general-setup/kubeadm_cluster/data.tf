# Note: As of Jan 2024... not used, AMI name no longer exist..
# Also locals.tf defines a hard coded AMI id during the recreation of the instances previously.

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = [var.ec2_ami_name]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = [var.ec2_ami_owner_id]
# }
