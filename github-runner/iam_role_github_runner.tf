resource "aws_iam_role" "github_runner" {
  name                 = "${local.csi}-${var.runner_name}"
  description          = "Role used by the github CICD runner instances"
  assume_role_policy   = data.aws_iam_policy_document.ec2_assumerole.json
  permissions_boundary = var.permissions_boundary_attachment
}

resource "aws_iam_instance_profile" "github_runner" {
  name = "${local.csi}-${var.runner_name}"
  role = aws_iam_role.github_runner.name
}

data "aws_iam_policy_document" "ec2_assumerole" {
  statement {
    sid    = "EcsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "github_runner_basic" {
  role       = aws_iam_role.github_runner.name
  policy_arn = aws_iam_policy.github_runner_basic.arn
}

resource "aws_iam_role_policy_attachment" "github_runner_extra" {
  count      = length(var.extra_policy_attachments)
  role       = aws_iam_role.github_runner.name
  policy_arn = var.extra_policy_attachments[count.index]
}

resource "aws_iam_policy" "github_runner_basic" {
  name        = "${local.csi}-${var.runner_name}"
  description = "Allow github runner to write its own logs and pull its own containers etc"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_runner_basic.json
}

data "aws_iam_policy_document" "github_runner_basic" {
  statement {
    sid    = "AllowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${var.parameter_bundle.region}:${local.this_account}:log-group:*",
      "arn:aws:logs:${var.parameter_bundle.region}:${local.this_account}:log-group:*",
    ]
  }

  statement {
    sid    = "AllowMetrics"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowEcrPull"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowEcrAuth"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowAssumeDeployRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::*:role/${split("/", var.parameter_bundle.iam_resource_arns.deployment_superuser_role)[1]}", # Assume the deployment superuser role in any account
      "arn:aws:iam::*:role/${split("/", var.parameter_bundle.iam_resource_arns.app_deployer_role)[1]}",         # Assume the app deployer role in any account
    ]
  }
}
