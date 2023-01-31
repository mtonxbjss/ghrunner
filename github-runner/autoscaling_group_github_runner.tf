resource "aws_autoscaling_group" "github_runner" {
  name                = "${local.csi}-${var.runner_name}"
  min_size            = var.autoscaling_min
  max_size            = var.autoscaling_max
  desired_capacity    = var.autoscaling_desired
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "EC2"
  termination_policies = [
    "OldestInstance",
    "Default"
  ]

  launch_template {
    id      = aws_launch_template.github_runner.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
  ]

  dynamic "tag" {
    for_each = merge(
      local.default_tags,
      {
        Name = "${local.csi}-${var.runner_name}",
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }
}
