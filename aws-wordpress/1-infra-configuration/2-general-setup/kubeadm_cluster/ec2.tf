resource "aws_instance" "instances" {
  for_each = local.instances

  iam_instance_profile = each.value.iam_instance_profile_name

  launch_template {
    id = aws_launch_template.ec2_templates[each.key].id
    version = each.value.launch_template_version
  }

  tags = merge(each.value.tags, {
    Name = each.value.name
  })
}


resource "aws_launch_template" "ec2_templates" {
  for_each = local.instances

  name = "${each.key}_launch_template"

  image_id               = each.value.ami
  instance_type          = each.value.instance_type
  update_default_version = false
  key_name               = var.ec2_keypair_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_type           = "gp3"
    }
  }

  network_interfaces {
    network_interface_id = each.value.eni_id
  }

  iam_instance_profile {
    name = each.value.iam_instance_profile_name
  }

  placement {
    availability_zone = each.value.availability_zone
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(each.value.tags, {
      Name = each.value.name
    })
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }
}