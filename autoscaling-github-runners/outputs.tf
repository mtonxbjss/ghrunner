output "instance_role_id" {
  value = length(aws_iam_role.github_runner) > 0 ? aws_iam_role.github_runner.id : ""
}

output "instance_role_name" {
  value = length(aws_iam_role.github_runner) > 0 ? aws_iam_role.github_runner.name : ""
}

output "instance_role_arn" {
  value = length(aws_iam_role.github_runner) > 0 ? aws_iam_role.github_runner.arn : ""
}

output "launch_template_id" {
  value = length(aws_launch_template.github_runner) > 0 ? aws_launch_template.github_runner.id : ""
}

output "launch_template_arn" {
  value = length(aws_launch_template.github_runner) > 0 ? aws_launch_template.github_runner.arn : ""
}

output "auto_scaling_group_name" {
  value = length(aws_autoscaling_group.github_runner) > 0 ? aws_autoscaling_group.github_runner.name : ""
}

output "auto_scaling_group_arn" {
  value = length(aws_autoscaling_group.github_runner) > 0 ? aws_autoscaling_group.github_runner.arn : ""
}

output "instance_profile_name" {
  value = length(aws_iam_instance_profile.github_runner) > 0 ? aws_iam_instance_profile.github_runner.name : ""
}

output "instance_profile_arn" {
  value = length(aws_iam_instance_profile.github_runner) > 0 ? aws_iam_instance_profile.github_runner.arn : ""
}

output "security_group_name" {
  value = length(aws_security_group.github_runner) > 0 ? aws_security_group.github_runner.name : ""
}

output "security_group_arn" {
  value = length(aws_security_group.github_runner) > 0 ? aws_security_group.github_runner.arn : ""
}

output "security_group_id" {
  value = length(aws_security_group.github_runner) > 0 ? aws_security_group.github_runner.id : ""
}

output "github_pat_secret_arn" {
  value = aws_secretsmanager_secret.github_pat.arn
}
