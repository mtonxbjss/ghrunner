resource "aws_cloudwatch_event_rule" "github_metrics" {
  name                = "${local.csi}-${var.runner_name}-github-metrics"
  description         = "Trigger the GitLab metrics Lambda function on a schedule"
  is_enabled          = true
  schedule_expression = "cron(0/1 07-19 ? * MON-FRI *)" # runs every minute between 0700-1959 Monday-Friday UTC (0800-2059 during BST)
  event_bus_name      = "default"
  role_arn            = aws_iam_role.trigger_github_metrics.arn
  tags                = local.default_tags
}

resource "aws_cloudwatch_event_target" "github_metrics" {
  rule           = aws_cloudwatch_event_rule.github_metrics.name
  event_bus_name = "default"
  target_id      = "GitLabMetrics"
  arn            = aws_lambda_function.github_metrics.arn
}
