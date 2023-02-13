resource "aws_imagebuilder_image_pipeline" "github" {
  name                             = "${var.unique_prefix}-imgbld-github-ami"
  description                      = "Default image pipeline for all GitHub Runner images"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.github.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.github.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.github.arn

  schedule {
    schedule_expression = "cron(${var.ami_build_pipeline_cron_expression})"
  }
}
