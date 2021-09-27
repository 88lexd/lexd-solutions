resource "aws_security_group" "SG_EC2" {
  name        = "SG-EC2"
  description = "Allow traffic into EC2"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    # My non-static public IP problem: not required to allow SSH to the world anymore.
    # Using this Python script to update SG - https://github.com/88lexd/lexd-solutions/tree/main/misc-scripts/python-aws-update-sg
    # {
    #   description      = "Allow SSH"
    #   from_port        = 22
    #   to_port          = 22
    #   protocol         = "tcp"
    #   cidr_blocks      = ["0.0.0.0/0"]
    #   ipv6_cidr_blocks = null
    #   prefix_list_ids  = null
    #   security_groups  = null
    #   self             = null
    # },
    {
      description      = "Allow HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow NFS"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      self             = true
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
      Name = "Allow traffic into EC2"
  }
}
