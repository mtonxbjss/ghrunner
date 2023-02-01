resource "aws_autoscaling_group" "github_runner" {
  name                = "${var.unique_prefix}-${var.ec2_github_runner_name}"
  min_size            = var.ec2_autoscaling_minimum_instances
  max_size            = var.ec2_autoscaling_maximum_instances
  desired_capacity    = var.ec2_autoscaling_desired_instances
  vpc_zone_identifier = var.ec2_subnet_ids
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
      local.resource_tags,
      {
        Name = "${var.unique_prefix}-${var.ec2_github_runner_name}",
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
