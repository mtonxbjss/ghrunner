resource "aws_security_group" "github_runner" {
  name        = "${var.unique_prefix}-${var.ec2_github_runner_name}"
  vpc_id      = var.ec2_vpc_id
  description = "github Runner Instance ${var.ec2_github_runner_name}"

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.unique_prefix}-${var.ec2_github_runner_name}"
    }
  )
}
