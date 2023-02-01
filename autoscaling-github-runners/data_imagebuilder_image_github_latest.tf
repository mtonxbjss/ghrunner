data "aws_imagebuilder_image" "github_latest" {
  arn = var.ec2_imagebuilder_image_arn
}
