locals {
  imagebuilder_components = toset(
    flatten(
      [
        ["common_packages"],
        ["download_runner_binary"],
        length(var.github_job_image_ecr_account) == 0 ? [] : ["docker_images"]
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
