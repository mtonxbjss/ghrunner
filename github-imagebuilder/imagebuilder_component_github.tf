resource "aws_imagebuilder_component" "github" {
  for_each = local.imagebuilder_components

  name = format("%s-%s",
    var.unique_prefix,
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
      ECR_ACCOUNT_ID            = var.parameter_bundle.account_ids["caas-${var.parameter_bundle.environment}"]
      RUNNER_BINARY_BUCKET_PATH = "s3://${var.github_runner_binary_bucket_name}/${var.github_runner_binary_bucket_path}"
      DOCKER_REGISTRY_ID        = var.docker_registry_id
      REGION                    = var.region
    }
  )
}
