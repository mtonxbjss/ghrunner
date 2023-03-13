resource "aws_imagebuilder_component" "github" {
  for_each = local.imagebuilder_components

  name = format("%s-%s-%s",
    var.unique_prefix,
    "imgbld-tf-container",
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
      REGION = var.region
    }
  )
}
