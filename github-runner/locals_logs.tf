locals {
  github_runner_log_prefix = "/${var.parameter_bundle.environment}/${var.parameter_bundle.component}/github/${var.runner_name}"
  github_runner_log_files = {
    "/var/log/apt/history.log"                                          = "%b %d %H:%M:%S"
    "/var/log/auth.log"                                                 = "%b %d %H:%M:%S"
    "/var/log/cloud-init.log"                                           = "%b %d %H:%M:%S"
    "/var/log/cloud-init-output.log"                                    = "%b %d %H:%M:%S"
    "/var/log/syslog"                                                   = "%b %d %H:%M:%S"
    "/var/log/amazon/ssm/amazon-ssm-agent.log"                          = "%Y-%m-%d %H:%M:%S"
    "/var/log/github-scale-in-protection.log"                           = "%Y-%m-%d %H:%M:%S"
    "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log" = "%Y-%m-%dT%H:%M:%S"
  }

  cloudwatch_agent_config = templatefile(
    "${path.module}/templates/cloudwatch_agent_config.tmpl.json",
    {
      LOG_GROUP_PREFIX = local.github_runner_log_prefix
      LOG_FILES        = local.github_runner_log_files
    }
  )

  cloudwatch_logs_metric_filters_namespace = "${local.csi}-metrics"
}
