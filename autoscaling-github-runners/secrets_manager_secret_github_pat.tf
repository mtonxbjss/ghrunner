resource "aws_secretsmanager_secret" "github_pat" {
  name                           = "${var.unique_prefix}-${var.ec2_github_runner_name}-pat"
  description                    = "Personal Access Token for GitHub Runners to use in order to register with GitHub"
  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0
}

resource "aws_secretsmanager_secret_version" "github_pat" {
  secret_id     = aws_secretsmanager_secret.github_pat.id
  secret_string = "placeholder-manually-replace-with-real-token"
}

resource "aws_secretsmanager_secret_policy" "github_pat" {
  secret_arn = aws_secretsmanager_secret.github_pat.arn
  policy     = data.aws_iam_policy_document.github_pat.json
}

data "aws_iam_policy_document" "github_pat" {
  statement {
    sid    = "AllowAdminAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = flatten([
        var.ec2_terraform_deployment_roles,
        var.iam_roles_with_admin_access_to_created_resources
      ])
    }
    actions = [
      "secretsmanager:*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowRunnerAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = flatten([
        [aws_iam_role.github_runner.arn],
        var.iam_roles_with_read_access_to_created_resources
      ])
    }
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "*"
    ]
  }
}
