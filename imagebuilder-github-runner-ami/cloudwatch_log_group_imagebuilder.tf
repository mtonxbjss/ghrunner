resource "aws_cloudwatch_log_group" "imagebuilder" {
  name              = "/aws/imagebuilder/${var.unique_prefix}-imgbld-github-ami"
  retention_in_days = 7
}
