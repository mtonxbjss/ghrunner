data "aws_imagebuilder_image" "github_latest" {
  arn = format(
    "arn:aws:imagebuilder:%s:%s:image/%s-imgbld/x.x.x",
    var.parameter_bundle.region,
    var.parameter_bundle.account_ids[var.parameter_bundle.account_name],
    local.csi
  )
}
