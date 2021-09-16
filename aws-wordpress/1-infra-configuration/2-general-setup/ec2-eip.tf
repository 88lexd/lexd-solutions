data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name = "My Instance"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "alex-lexdsolutions"  # This key must already exist! Unfortunately cannot automate this.
  vpc_security_group_ids = [aws_security_group.SG_EC2.id]
  subnet_id              = module.vpc.public_subnets[0]

}

resource "aws_eip" "ec2-eip" {
  instance = module.ec2_instance.id
  vpc      = true
  depends_on = [module.vpc.vpc_id]
  tags = {
      Name = "EIP for MasterNode"
  }
}

