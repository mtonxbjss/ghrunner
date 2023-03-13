data "aws_imagebuilder_image" "github_latest" {
  count = length(var.ec2_imagebuilder_image_arn) > 0 ? 1 : 0
  arn   = var.ec2_imagebuilder_image_arn
}
