locals {
  imagebuilder_components = toset([
    "common_packages",
    "tfenv"
  ])

  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/imagebuilder-terraform-container",
    },
    var.resource_tags
  )
}
