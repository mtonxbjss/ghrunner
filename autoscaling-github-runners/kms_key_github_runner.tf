resource "aws_kms_key" "github_runner" {
  description             = "CMK for encrypting github Runner Volumes"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_github_runner.json
  tags                    = local.resource_tags
}

resource "aws_kms_alias" "github_runner" {
  name          = "alias/${var.unique_prefix}-github-runner-${var.ec2_github_runner_name}"
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
      "kms:TagResource",
      "kms:PutKeyPolicy",
    ]
    resources = [
      "*",
    ]
    principals {
      type        = "AWS"
      identifiers = length(var.iam_roles_with_admin_access_to_created_resources) > 0 ? var.iam_roles_with_admin_access_to_created_resources : ["arn:aws:iam::${var.runner_account_id}:root"]
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
        "arn:aws:iam::${var.runner_account_id}:root",
        "arn:aws:iam::${var.runner_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
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
        "arn:aws:iam::${var.runner_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
