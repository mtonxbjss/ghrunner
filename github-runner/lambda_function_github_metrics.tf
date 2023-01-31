resource "aws_lambda_function" "github_metrics" {
  depends_on = [
    aws_cloudwatch_log_group.github_metrics
  ]
  filename         = data.archive_file.github_metrics_zip.output_path
  role             = aws_iam_role.github_metrics.arn
  function_name    = "${local.csi}-${var.runner_name}-metrics"
  description      = "Lambda gathers github metrics and creates cloudwatch metrics"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 10
  memory_size      = 128
  publish          = true
  source_code_hash = data.archive_file.github_metrics_zip.output_base64sha256
  tags             = local.default_tags

  environment {
    variables = {
      ENVIRONMENT            = var.parameter_bundle.environment
      GITHUB_PAT_SSM_PATH    = var.github_server_pat_ssm_param_name
      TAG_LIST               = var.tag_list
      GITHUB_CAAS_OWNER      = "NHSDigital"
      GITHUB_CAAS_REPO_NAMES = var.github_repo_name
      CLOUDWATCH_NAMESPACE   = local.cloudwatch_logs_metric_filters_namespace
    }
  }
}

data "archive_file" "github_metrics_zip" {
  type        = "zip"
  output_path = "${path.root}/github_metrics.zip"
  source {
    content  = file("${path.module}/files/github_metrics.js")
    filename = "index.js"
  }
}

resource "aws_lambda_permission" "github_metrics_from_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_metrics.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.github_metrics.arn
}
