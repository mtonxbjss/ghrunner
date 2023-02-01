resource "aws_imagebuilder_container_recipe" "github" {
  name           = "${var.unique_prefix}-imgbld-tf-container"
  description    = "AWS ImageBuilder Recipe for creating new GitHub Runner Job container images for the TechTest"
  version        = var.container_version_number
  container_type = "DOCKER"
  parent_image   = "ubuntu:20.04"

  target_repository {
    repository_name = var.ecr_private_repository_name
    service         = "ECR"
  }

  # python 3
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/python-3-linux/1.0.2/1"
  }

  # aws cli
  component {
    component_arn = "arn:aws:imagebuilder:eu-west-2:aws:component/aws-cli-version-2-linux/1.0.3/1"
  }

  # our own bespoke components
  dynamic "component" {
    for_each = local.imagebuilder_components
    content {
      component_arn = aws_imagebuilder_component.github[component.key].arn
    }
  }

  dockerfile_template_data = <<EOF
FROM {{{ imagebuilder:parentImage }}}
ENV AWS_DEFAULT_REGION "eu-west-2"
{{{ imagebuilder:environments }}}
{{{ imagebuilder:components }}}
ENTRYPOINT ["/bin/bash", "-l", "-c"]
EOF
}
