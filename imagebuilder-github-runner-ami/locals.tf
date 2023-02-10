locals {
  imagebuilder_components = toset(
    flatten(
      [
        ["common_packages"],
        length(var.github_runner_binary_bucket_name) == 0 ? ["download_runner_binary_from_source"] : ["download_runner_binary"],
        length(var.github_job_image_ecr_account_id) == 0 ? [] : ["docker_images"]
      ]
    )
  )

  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/imagebuilder-github-runner-ami",
    },
    var.resource_tags
  )
}
