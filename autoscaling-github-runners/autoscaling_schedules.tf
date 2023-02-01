#@filename_check_ignore - file contains multiple policies of equal importance so plural filename is ok

resource "aws_autoscaling_schedule" "scale_in" {
  count                  = var.ec2_nightly_shutdown_enabled ? 1 : 0
  scheduled_action_name  = "${var.unique_prefix}-scale-in"
  desired_capacity       = 0
  min_size               = 0
  max_size               = -1
  recurrence             = var.ec2_nightly_shutdown_scale_in_time
  autoscaling_group_name = aws_autoscaling_group.github_runner.name
}

resource "aws_autoscaling_schedule" "scale_out" {
  count                  = var.ec2_nightly_shutdown_enabled ? 1 : 0
  scheduled_action_name  = "${var.unique_prefix}-scale-out"
  desired_capacity       = var.ec2_autoscaling_desired_instances
  min_size               = var.ec2_autoscaling_minimum_instances
  max_size               = -1
  recurrence             = var.ec2_nightly_shutdown_scale_out_time
  autoscaling_group_name = aws_autoscaling_group.github_runner.name
}
