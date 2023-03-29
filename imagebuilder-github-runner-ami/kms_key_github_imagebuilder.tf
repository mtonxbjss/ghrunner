resource "aws_kms_key" "github_imagebuilder" {
  count                   = var.imagebuilder_ec2_encryption == "CMK" ? 1 : 0
  description             = "CMK for encrypting github Runner Volumes"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_github_imagebuilder[0].json
  tags                    = local.resource_tags
}

resource "aws_kms_alias" "github_imagebuilder" {
  count         = var.imagebuilder_ec2_encryption == "CMK" ? 1 : 0
  name          = "alias/${var.unique_prefix}-imgbld-github-ami"
  target_key_id = aws_kms_key.github_imagebuilder[0].key_id
}

data "aws_iam_policy_document" "kms_key_github_imagebuilder" {
  count = var.imagebuilder_ec2_encryption == "CMK" ? 1 : 0
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
      identifiers = var.iam_roles_with_admin_access_to_created_resources
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
      identifiers = flatten([
        ["arn:aws:iam::${var.runner_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"],
        ["arn:aws:iam::${var.runner_account_id}:root"],
        [for account in var.ami_sharing_account_id_list : "arn:aws:iam::${account}:root"],
        [for account in var.ami_sharing_account_id_list : "arn:aws:iam::${account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"],
      ])
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
        "arn:aws:iam::${var.runner_account_id}:role/aws-service-role/imagebuilder.amazonaws.com/AWSServiceRoleForImageBuilder",
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
