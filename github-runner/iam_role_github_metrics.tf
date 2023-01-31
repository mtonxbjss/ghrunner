resource "aws_iam_role" "github_metrics" {
  name                 = "${local.csi}-${var.runner_name}-metrics"
  description          = "Role used by lambda to gather github metrics and create cloudwatch metrics"
  assume_role_policy   = data.aws_iam_policy_document.github_metrics_assumerole.json
  permissions_boundary = var.parameter_bundle.iam_resource_arns["permission_boundary"]
}

data "aws_iam_policy_document" "github_metrics_assumerole" {
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
  role       = aws_iam_role.github_metrics.name
  policy_arn = aws_iam_policy.github_metrics.arn
}

resource "aws_iam_policy" "github_metrics" {
  name        = "${local.csi}-${var.runner_name}-metrics"
  description = "Allow Lambda to write its own logs and create github metrics"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_metrics.json
}

data "aws_iam_policy_document" "github_metrics" {
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
      "arn:aws:logs:eu-west-2:${local.this_account}:log-group:/aws/lambda/${local.csi}-*"
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
    sid    = "AllowSSMGetParam"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      var.github_server_pat_ssm_param_arn,
    ]
  }
}
