# resource "aws_cloudwatch_log_metric_filter" "github_failed" {
#   depends_on = [
#     aws_cloudwatch_log_group.github_runner
#   ]

#   name           = "githubRunnerFailed"
#   pattern        = "?\"couldn't execute POST\" ?\"forbidden\" ?\"is not healthy\""
#   log_group_name = "${local.github_runner_log_prefix}/var/log/messages"

#   metric_transformation {
#     name          = var.cloudwatch_metric_github_runner_failure_name
#     namespace     = local.cloudwatch_logs_metric_filters_namespace
#     value         = "1"
#     default_value = "0"
#   }
# }
