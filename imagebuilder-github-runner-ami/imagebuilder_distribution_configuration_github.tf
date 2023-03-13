resource "aws_imagebuilder_distribution_configuration" "github" {
  name        = "${var.unique_prefix}-imgbld-github-ami"
  description = "Distribution config for GitHub Runners for GitHub"

  distribution {
    ami_distribution_configuration {
      name       = "${var.unique_prefix}-{{ imagebuilder:buildDate }}"
      ami_tags   = local.resource_tags
      kms_key_id = var.imagebuilder_ec2_encryption == "CMK" ? aws_kms_key.github_imagebuilder[0].arn : var.imagebuilder_ec2_encryption == "AWS" ? data.aws_kms_key.aws_ebs.arn : null

      launch_permission {
        user_ids = flatten([
          [var.runner_account_id],
          var.ami_sharing_account_id_list,
        ])
      }
    }

    region = var.region
  }
}
