# resource "aws_cloudwatch_metric_alarm" "github_failed" {
#   alarm_name          = "${local.csi}-connect-failed"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "githubRunnerFailureCount"
#   namespace           = local.cloudwatch_logs_metric_filters_namespace
#   period              = "300"
#   statistic           = "Sum"
#   threshold           = "1"
#   alarm_description   = "RELIABILITY: This metric warns if a github runner has failed to connect to the server"
#   alarm_actions       = []
# }
