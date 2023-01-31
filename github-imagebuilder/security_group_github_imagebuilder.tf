resource "aws_security_group" "github_imagebuilder" {
  name        = var.unique_prefix
  vpc_id      = var.main_vpc_id
  description = "GitHub Imagebuilder Instance"

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.unique_prefix}"
    }
  )
}
