resource "aws_cloudwatch_log_group" "github_runner" {
  for_each = local.github_runner_log_files

  name = format(
    "%s%s",
    local.github_runner_log_prefix,
    each.key,
  )

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "github_metrics" {
  count             = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name              = "/aws/lambda/${var.unique_prefix}-${var.ec2_github_runner_name}-metrics"
  retention_in_days = 1 // don't need to keep these logs beyond the current day
}
