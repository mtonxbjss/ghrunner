resource "aws_imagebuilder_infrastructure_configuration" "github" {
  name                          = "${var.unique_prefix}-imgbld-tf-container"
  description                   = "Infrastructure config for building GitHub Actions Job Container Images"
  instance_profile_name         = aws_iam_instance_profile.github_image_builder.name
  instance_types                = [var.imagebuilder_ec2_instance_type]
  subnet_id                     = var.imagebuilder_ec2_subnet_id
  terminate_instance_on_failure = var.imagebuilder_ec2_terminate_on_failure

  security_group_ids = flatten([
    [aws_security_group.github_imagebuilder.id],
    var.imagebuilder_ec2_extra_security_groups
  ])

  logging {
    s3_logs {
      s3_bucket_name = var.imagebuilder_log_bucket_name
      s3_key_prefix  = var.imagebuilder_log_bucket_path
    }
  }
}
