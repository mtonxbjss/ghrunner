output "imagebuilder_image_arn_xxx" {
  description = "ImageBuilder resulting image ARN with x.x.x placeholders to denote latest-version"
  value       = "arn:aws:imagebuilder:${var.region}:${var.runner_account_id}:image/${var.unique_prefix}-imgbld-github-ami/x.x.x"
}
