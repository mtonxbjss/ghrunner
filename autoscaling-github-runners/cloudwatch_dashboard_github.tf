resource "aws_cloudwatch_dashboard" "account" {
  dashboard_name = "${var.unique_prefix}-${var.ec2_github_runner_name}"

  # These variables must be the superset of all variables required by the cohort explorer dashboards
  dashboard_body = templatefile(
    "${path.module}/templates/github_dashboard_template.tmpl.json",
    {
      RUNNER_NAME            = var.ec2_github_runner_name
      UPPER_RUNNER_NAME      = upper(var.ec2_github_runner_name)
      AUTOSCALING_GROUP_NAME = aws_autoscaling_group.github_runner.name
      METRICS_NAMESPACE      = local.cloudwatch_logs_metric_filters_namespace
      INSTANCE_TYPE          = var.ec2_instance_type
      TAG_LIST               = var.ec2_github_runner_tag_list
    }
  )
}
