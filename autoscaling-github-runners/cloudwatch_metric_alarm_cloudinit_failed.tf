resource "aws_cloudwatch_metric_alarm" "cloudinit_failed" {
  alarm_name          = "${var.unique_prefix}-cloudinit-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.cloudwatch_metric_cloud_init_failure_name
  namespace           = local.cloudwatch_logs_metric_filters_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "RELIABILITY: This metric warns if the cloud-init processing has failed on one or more instances"
  alarm_actions       = []
}
