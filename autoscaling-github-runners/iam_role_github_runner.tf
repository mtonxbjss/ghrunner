resource "aws_iam_role" "github_runner" {
  name                 = "${var.unique_prefix}-${var.ec2_github_runner_name}"
  description          = "Role used by the github CICD runner instances"
  assume_role_policy   = data.aws_iam_policy_document.ec2_assumerole.json
  permissions_boundary = var.permission_boundary_arn
}

resource "aws_iam_instance_profile" "github_runner" {
  name = "${var.unique_prefix}-${var.ec2_github_runner_name}"
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
  count      = length(var.ec2_iam_role_extra_policy_attachments)
  role       = aws_iam_role.github_runner.name
  policy_arn = var.ec2_iam_role_extra_policy_attachments[count.index]
}

resource "aws_iam_policy" "github_runner_basic" {
  name        = "${var.unique_prefix}-${var.ec2_github_runner_name}"
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
      "arn:aws:logs:${var.region}:${var.runner_account_id}:log-group:*",
      "arn:aws:logs:${var.region}:${var.runner_account_id}:log-group:*",
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
    sid    = "AllowRunnersToRefreshThemselves"
    effect = "Allow"
    actions = [
      "autoscaling:StartInstanceRefresh",
    ]
    resources = [
      aws_autoscaling_group.github_runner.arn,
    ]
  }

  statement {
    sid    = "AllowEcrPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
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

  statement {
    sid    = "AllowSsmSessionManager"
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
    ]

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = length(var.ec2_terraform_deployment_roles) > 0 ? ["1"] : []
    content {
      sid    = "AllowAssumeDeployRole"
      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      resources = var.ec2_terraform_deployment_roles

    }
  }

  dynamic "statement" {
    for_each = length(var.cicd_artifacts_bucket_name) > 0 ? ["1"] : []
    content {
      sid    = "AllowS3CICDAccess"
      effect = "Allow"

      actions = [
        "s3:Get*",
        "s3:Head*",
        "s3:List*",
        "s3:DeleteObject*",
        "s3:PutObject*",
      ]

      resources = [
        "arn:aws:s3:::${var.cicd_artifacts_bucket_name}",
        "arn:aws:s3:::${var.cicd_artifacts_bucket_name}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.state_bucket_name) > 0 ? ["1"] : []
    content {
      sid    = "AllowS3StateAccess"
      effect = "Allow"

      actions = [
        "s3:Get*",
        "s3:Head*",
        "s3:List*",
        "s3:DeleteObject*",
        "s3:PutObject*",
      ]

      resources = [
        "arn:aws:s3:::${var.state_bucket_name}",
        "arn:aws:s3:::${var.state_bucket_name}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.cicd_artifacts_bucket_key_arn) > 0 ? ["1"] : []
    content {
      sid    = "AllowKMSCICD"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:ListGrants",
        "kms:ListResourceTags",
        "kms:ReEncrypt*",
      ]

      resources = [
        var.cicd_artifacts_bucket_key_arn,
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.state_bucket_key_arn) > 0 ? ["1"] : []
    content {
      sid    = "AllowKMSState"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:ListGrants",
        "kms:ListResourceTags",
        "kms:ReEncrypt*",
      ]

      resources = [
        var.state_bucket_key_arn,
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.state_lock_table_arn) > 0 ? ["1"] : []
    content {
      sid    = "AllowDynamoDBStateLock"
      effect = "Allow"

      actions = [
        "dynamodb:UpdateItem",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ]

      resources = [
        var.state_lock_table_arn,
      ]
    }
  }
}
