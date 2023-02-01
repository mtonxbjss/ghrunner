resource "aws_iam_role" "trigger_github_metrics" {
  name                 = "${var.unique_prefix}-${var.ec2_github_runner_name}-trigger-github-metrics"
  description          = "Role used by the eventbridge schedule to trigger the github metrics lambda"
  assume_role_policy   = data.aws_iam_policy_document.trigger_github_metrics_assumerole.json
  permissions_boundary = var.permission_boundary_arn
}

data "aws_iam_policy_document" "trigger_github_metrics_assumerole" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "trigger_github_metrics" {
  role       = aws_iam_role.trigger_github_metrics.name
  policy_arn = aws_iam_policy.trigger_github_metrics.arn
}

resource "aws_iam_policy" "trigger_github_metrics" {
  name        = "${var.unique_prefix}-${var.ec2_github_runner_name}-trigger-github-metrics"
  description = "Allow eventbridge permission to invoke a lambda"
  path        = "/"
  policy      = data.aws_iam_policy_document.trigger_github_metrics.json
}

data "aws_iam_policy_document" "trigger_github_metrics" {
  statement {
    sid    = "AllowInvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      "${aws_lambda_function.github_metrics.arn}:*",
    ]
  }
}
