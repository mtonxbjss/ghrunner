resource "aws_imagebuilder_distribution_configuration" "github" {
  name        = "${var.unique_prefix}-imgbld-tf-container"
  description = "Distribution config for GitHub Actions Job Container Images"

  distribution {
    container_distribution_configuration {
      description = "GitHub Actions Job Container Image"
      target_repository {
        repository_name = var.ecr_private_repository_name
        service         = "ECR"
      }
      container_tags = [
        "latest"
      ]
    }
    region = var.region
  }
}
