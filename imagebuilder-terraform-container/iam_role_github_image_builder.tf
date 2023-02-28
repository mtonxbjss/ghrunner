resource "aws_iam_role" "github_image_builder" {
  name                 = "${var.unique_prefix}-imgbld-tf-container"
  description          = "Role used by the EC2 Image Builder to create GitHub CICD runner images"
  assume_role_policy   = data.aws_iam_policy_document.github_image_builder_assumerole.json
  permissions_boundary = var.permission_boundary_arn
}

resource "aws_iam_instance_profile" "github_image_builder" {
  name = "${var.unique_prefix}-imgbld-tf-container"
  role = aws_iam_role.github_image_builder.name
}

data "aws_iam_policy_document" "github_image_builder_assumerole" {
  statement {
    sid    = "Ec2AssumeRole"
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

resource "aws_iam_role_policy_attachment" "github_image_builder" {
  role       = aws_iam_role.github_image_builder.name
  policy_arn = aws_iam_policy.github_image_builder.arn
}

resource "aws_iam_policy" "github_image_builder" {
  name        = "${var.unique_prefix}-imgbld-tf-container"
  description = "Allow AWS Image Builder to write its own logs and pull its own resources"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_image_builder.json
}

data "aws_iam_policy_document" "github_image_builder" {
  statement {
    sid    = "AllowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.runner_account_id}:log-group/aws/imagebuilder/*",
    ]
  }

  statement {
    sid    = "AllowS3Get"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::ec2imagebuilder*",
    ]
  }

  statement {
    sid    = "AllowS3Put"
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.imagebuilder_log_bucket_name}",
      "arn:aws:s3:::${var.imagebuilder_log_bucket_name}/${var.imagebuilder_log_bucket_path}/*",
    ]
  }

  statement {
    sid    = "AllowImageBuilder"
    effect = "Allow"
    actions = [
      "imagebuilder:GetComponent",
      "imagebuilder:GetContainerRecipe",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowKmsDecryptViaImageBuilder"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = flatten([
      [aws_kms_key.github_imagebuilder.arn],
      length(var.imagebuilder_log_bucket_encryption_key_arn) == 0 ? [] : [var.imagebuilder_log_bucket_encryption_key_arn],
    ])
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:EncryptionContextKeys"
      values   = ["aws:imagebuilder:arn"]
    }
  }

  statement {
    sid    = "AllowKmsDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = flatten([
      [aws_kms_key.github_imagebuilder.arn],
      length(var.imagebuilder_log_bucket_encryption_key_arn) == 0 ? [] : [var.imagebuilder_log_bucket_encryption_key_arn],
    ])
  }

  statement {
    sid    = "AllowIntegrationWithSsm"
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
    for_each = length(var.ecr_private_repository_account_id) == 0 ? toset([]) : toset([1])
    content {
      sid    = "AllowEcrPull"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
      resources = [
        "arn:aws:ecr:${var.region}:${var.ecr_private_repository_account_id}:repository/${var.ecr_private_repository_name}",
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.ecr_private_repository_account_id) == 0 ? toset([]) : toset([1])
    content {
      sid    = "AllowEcrAuth"
      effect = "Allow"
      actions = [
        "ecr:GetAuthorizationToken",
      ]
      resources = [
        "*",
      ]
    }
  }
}
