resource "aws_imagebuilder_image_pipeline" "github" {
  name                             = "${var.unique_prefix}-imgbld-tf-container"
  description                      = "Default image pipeline for all GitHub Actions Job Docker Images"
  container_recipe_arn             = aws_imagebuilder_container_recipe.github.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.github.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.github.arn

  schedule {
    schedule_expression = "cron(${var.container_build_pipeline_cron_expression})"
  }
}
