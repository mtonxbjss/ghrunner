#@filename_check_ignore - file contains multiple policies of equal importance so plural filename is ok

resource "aws_autoscaling_schedule" "scale_in" {
  count                  = var.nightly_shutdown ? 1 : 0
  scheduled_action_name  = "${local.csi}-scale-in"
  desired_capacity       = 1
  min_size               = 1
  max_size               = -1
  recurrence             = var.scale_in_time
  autoscaling_group_name = aws_autoscaling_group.github_runner.name
}

resource "aws_autoscaling_schedule" "scale_out" {
  count                  = var.nightly_shutdown ? 1 : 0
  scheduled_action_name  = "${local.csi}-scale-out"
  desired_capacity       = var.autoscaling_desired
  min_size               = var.autoscaling_min
  max_size               = -1
  recurrence             = var.scale_out_time
  autoscaling_group_name = aws_autoscaling_group.github_runner.name
}
