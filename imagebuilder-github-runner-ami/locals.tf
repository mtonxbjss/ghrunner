locals {
  imagebuilder_components = toset([
    "common_packages",
    "download_runner_binary",
    "docker_images"
  ])

  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/imagebuilder-github-runner-ami",
    },
    var.resource_tags
  )
}
