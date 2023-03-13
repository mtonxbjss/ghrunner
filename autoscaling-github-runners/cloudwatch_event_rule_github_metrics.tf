resource "aws_cloudwatch_event_rule" "github_metrics" {
  count               = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name                = "${var.unique_prefix}-${var.ec2_github_runner_name}-github-metrics"
  description         = "Trigger the GitHub metrics Lambda function on a schedule"
  is_enabled          = var.ec2_dynamic_scaling_enabled
  schedule_expression = "cron(${var.ec2_dynamic_scaling_metric_collection_cron_expression})"
  event_bus_name      = "default"
  role_arn            = aws_iam_role.trigger_github_metrics[0].arn
  tags                = local.resource_tags
}

resource "aws_cloudwatch_event_target" "github_metrics" {
  count          = var.ec2_dynamic_scaling_enabled ? 1 : 0
  rule           = aws_cloudwatch_event_rule.github_metrics[0].name
  event_bus_name = "default"
  target_id      = "GitHubMetrics"
  arn            = aws_lambda_function.github_metrics[0].arn
}
