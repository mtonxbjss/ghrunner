resource "aws_security_group" "github_imagebuilder" {
  name        = "${var.unique_prefix}-imgbld-tf-container"
  vpc_id      = var.imagebuilder_ec2_vpc_id
  description = "GitHub Imagebuilder Instance"

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.unique_prefix}-imgbld-tf-container"
    }
  )
}
