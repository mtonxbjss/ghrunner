resource "aws_imagebuilder_image_recipe" "github" {
  name         = "${var.unique_prefix}-imgbld-github-ami"
  description  = "AWS ImageBuilder Recipe for creating new GitHub Runner images for GitHub"
  parent_image = data.aws_ami.ubuntu_latest.image_id
  version      = var.ami_version_number

  block_device_mapping {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = contains(["AWS", "CMK"], var.imagebuilder_ec2_encryption) ? true : false
      kms_key_id            = var.imagebuilder_ec2_encryption == "CMK" ? aws_kms_key.github_imagebuilder[0].arn : var.imagebuilder_ec2_encryption == "AWS" ? data.aws_kms_key.aws_ebs.arn : null
      volume_size           = var.imagebuilder_ec2_root_volume_size
      volume_type           = "gp2"
    }
  }

  # python 3
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/python-3-linux/1.0.2/1"
  }

  # amazon cloudwatch agent
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1"
  }

  # aws cli
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/aws-cli-version-2-linux/1.0.3/1"
  }

  # docker community edition
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/docker-ce-ubuntu/1.0.0/1"
  }

  dynamic "component" {
    for_each = local.imagebuilder_components
    content {
      component_arn = aws_imagebuilder_component.github[component.key].arn
    }
  }
}
