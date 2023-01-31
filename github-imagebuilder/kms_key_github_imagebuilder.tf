resource "aws_kms_key" "github_imagebuilder" {
  description             = "CMK for encrypting github Runner Volumes"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_github_imagebuilder.json
  tags                    = local.resource_tags
}

resource "aws_kms_alias" "github_imagebuilder" {
  name          = "alias/${var.unique_prefix}-github-imagebuilder"
  target_key_id = aws_kms_key.github_imagebuilder.key_id
}

data "aws_iam_policy_document" "kms_key_github_imagebuilder" {
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
