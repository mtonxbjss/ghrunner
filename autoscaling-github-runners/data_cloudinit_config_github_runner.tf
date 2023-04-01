data "cloudinit_config" "github_runner" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = templatefile(
      "${path.module}/templates/cloudinit_config.tmpl.yaml",
      {
        CLOUDWATCH_AGENT_CONFIG = local.cloudwatch_agent_config
        TF_ASG_NAME             = "${var.unique_prefix}-${var.ec2_github_runner_name}"
        REGION                  = var.region
        TAG_LIST                = replace(var.ec2_github_runner_tag_list, " ", "")
        CONCURRENT              = var.ec2_maximum_concurrent_github_jobs
        DOCKER_REGISTRY_ID      = "${var.github_job_image_ecr_account}.dkr.ecr.eu-west-2.amazonaws.com"
        GITHUB_ORG_URL          = var.github_organization_url
        GITHUB_REPO_NAMES       = var.github_repository_names
        PAT_SECRET_NAME         = aws_secretsmanager_secret.github_pat.name

        GITHUB_REPO_LIST = join(" ", [
          for repo_name in var.github_repository_names :
          "${var.github_organization_url}/${repo_name}"
        ])
      }
    )
  }
}
