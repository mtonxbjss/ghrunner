resource "aws_kms_key" "github_runner" {
  description             = "CMK for encrypting github Runner Volumes"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_github_runner.json
  tags                    = local.default_tags
}

resource "aws_kms_alias" "github_runner" {
  name          = "alias/${local.csi}-github-runner-${var.runner_name}"
  target_key_id = aws_kms_key.github_runner.key_id
}

data "aws_iam_policy_document" "kms_key_github_runner" {
  statement {
    sid    = "AllowLocalIAMAdministration"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.this_account}:root",
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToUse"
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
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.this_account}:root",
        "arn:aws:iam::${local.this_account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      ]
    }
  }

  statement {
    sid    = "AllowAutoscalingToUse"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.this_account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
