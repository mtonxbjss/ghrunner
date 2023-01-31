resource "aws_security_group" "github_runner" {
  name        = "${local.csi}-${var.runner_name}"
  vpc_id      = var.main_vpc_id
  description = "github Runner Instance ${var.runner_name}"

  tags = merge(
    local.default_tags,
    {
      Name = "${local.csi}-${var.runner_name}"
    }
  )
}
