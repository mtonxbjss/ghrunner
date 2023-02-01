resource "aws_cloudwatch_log_metric_filter" "cloudinit_failed" {
  depends_on = [
    aws_cloudwatch_log_group.github_runner
  ]

  name           = "CloudInitFailed"
  pattern        = "\"cloud-init\" \"failed\""
  log_group_name = "${local.github_runner_log_prefix}/var/log/syslog"

  metric_transformation {
    name          = var.cloudwatch_metric_cloud_init_failure_name
    namespace     = local.cloudwatch_logs_metric_filters_namespace
    value         = "1"
    default_value = "0"
  }
}
