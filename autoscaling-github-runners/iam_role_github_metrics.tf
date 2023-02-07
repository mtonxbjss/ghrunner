resource "aws_iam_role" "github_metrics" {
  count                = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name                 = "${var.unique_prefix}-${var.ec2_github_runner_name}-metrics"
  description          = "Role used by lambda to gather github metrics and create cloudwatch metrics"
  assume_role_policy   = data.aws_iam_policy_document.github_metrics_assumerole[0].json
  permissions_boundary = var.permission_boundary_arn
}

data "aws_iam_policy_document" "github_metrics_assumerole" {
  count = var.ec2_dynamic_scaling_enabled ? 1 : 0
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "github_metrics" {
  count      = var.ec2_dynamic_scaling_enabled ? 1 : 0
  role       = aws_iam_role.github_metrics[0].name
  policy_arn = aws_iam_policy.github_metrics[0].arn
}

resource "aws_iam_policy" "github_metrics" {
  count       = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name        = "${var.unique_prefix}-${var.ec2_github_runner_name}-metrics"
  description = "Allow Lambda to write its own logs and create github metrics"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_metrics[0].json
}

data "aws_iam_policy_document" "github_metrics" {
  count = var.ec2_dynamic_scaling_enabled ? 1 : 0

  statement {
    sid    = "AllowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${var.runner_account_id}:log-group:/aws/lambda/${var.unique_prefix}-*"
    ]
  }

  statement {
    sid    = "AllowCwMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowSecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.github_pat.arn
    ]
  }
}
