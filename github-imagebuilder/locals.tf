locals {
  # Compound Scope Identifier
  csi = replace(
    format(
      "%s-%s-%s-%s",
      var.parameter_bundle.project,
      var.parameter_bundle.environment,
      var.parameter_bundle.component,
      var.module,
    ),
    "_",
    "",
  )

  # CSI for use in resources with a global namespace, i.e. S3 Buckets
  csi_global = replace(
    format(
      "%s-%s-%s-%s-%s-%s",
      var.parameter_bundle.project,
      local.this_account,
      var.parameter_bundle.region,
      var.parameter_bundle.environment,
      var.parameter_bundle.component,
      var.module,
    ),
    "_",
    "",
  )

  resource_tags = {
    "Module" = var.module,
  }

  imagebuilder_components = toset([
    "common_packages",
    "download_runner_binary",
    "docker_images"
  ])
}
