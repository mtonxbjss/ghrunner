resource "aws_lambda_function" "github_metrics" {
  depends_on = [
    aws_cloudwatch_log_group.github_metrics
  ]
  filename         = data.archive_file.github_metrics_zip.output_path
  role             = aws_iam_role.github_metrics.arn
  function_name    = "${var.unique_prefix}-${var.ec2_github_runner_name}-metrics"
  description      = "Lambda gathers github metrics and creates cloudwatch metrics"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 10
  memory_size      = 128
  publish          = true
  source_code_hash = data.archive_file.github_metrics_zip.output_base64sha256
  tags             = local.resource_tags

  environment {
    variables = {
      GITHUB_PAT_SECRET_ARN = aws_secretsmanager_secret.github_pat.arn
      TAG_LIST              = var.ec2_github_runner_tag_list
      GITHUB_OWNER          = "NHSDigital"
      GITHUB_REPO_NAMES     = var.github_repository_name
      CLOUDWATCH_NAMESPACE  = local.cloudwatch_logs_metric_filters_namespace
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
