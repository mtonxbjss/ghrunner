locals {
  imagebuilder_components = toset([
    "common_packages",
    "tfenv",
    "kubectl"
  ])

  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/imagebuilder-terraform-container",
    },
    var.resource_tags
  )
}
