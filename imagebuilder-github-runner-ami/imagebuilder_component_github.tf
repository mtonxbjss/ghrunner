resource "aws_imagebuilder_component" "github" {
  for_each = local.imagebuilder_components

  name = format("%s-%s-%s",
    var.unique_prefix,
    "imgbld-github-ami",
    replace(each.key, "_", "-")
  )

  description = "${each.key} Component for building GitHub Runners"
  platform    = "Linux"
  version     = "1.0.0"

  data = templatefile(format("%s/%s/%s_%s.yaml",
    path.module,
    "files",
    "imagebuilder_component",
    each.key
    ),
    {
      ECR_ACCOUNT_ID            = var.runner_account_id
      RUNNER_BINARY_BUCKET_PATH = "s3://${var.github_runner_binary_bucket_name}/${var.github_runner_binary_bucket_path}"
      RUNNER_BINARY_SOURCE_PATH = "https://github.com/actions/runner/releases/download/v${var.github_runner_binary_version}/actions-runner-linux-x64-${var.github_runner_binary_version}.tar.gz"
      DOCKER_REGISTRY_ID        = length(var.github_job_image_ecr_account_id) > 0 ? "${var.github_job_image_ecr_account_id}.dkr.ecr.eu-west-2.amazonaws.com" : ""
      DOCKER_REPO_NAMES         = join(" ", var.github_job_image_ecr_repository_names)
      REGION                    = var.region
    }
  )
}
