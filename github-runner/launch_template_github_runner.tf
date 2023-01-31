resource "aws_launch_template" "github_runner" {
  name                                 = "${local.csi}-${var.runner_name}"
  description                          = "Template for the github runner ${var.runner_name} to be launched in a self-healing ASG"
  update_default_version               = true
  image_id                             = tolist(data.aws_imagebuilder_image.github_latest.output_resources[0].amis)[0].image
  instance_type                        = var.instance_type
  user_data                            = data.cloudinit_config.github_runner.rendered
  instance_initiated_shutdown_behavior = var.enable_spot ? "terminate" : "stop"
  ebs_optimized                        = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.github_runner.arn
      volume_size           = var.root_volume_size
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.github_runner.name
  }

  dynamic "instance_market_options" {
    for_each = var.enable_spot ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price          = var.spot_max_price
        spot_instance_type = "one-time"
      }
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = var.associate_public_ip
    security_groups = flatten([
      [aws_security_group.github_runner.id],
      var.extra_security_groups
    ])
    subnet_id = var.subnet_ids[0]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 5
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.default_tags,
      {
        "githubRole" = var.runner_role
      }
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.default_tags,
      {
        "githubRole" = var.runner_role
      }
    )
  }
}
