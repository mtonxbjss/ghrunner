locals {
  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/ec2-github-runner",
    },
    var.resource_tags
  )
}
