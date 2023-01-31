module "ssm_params_github_runner" {
  source = "../../shared_modules/ssm-parameters"
  module = "ssm"

  parameter_bundle = var.parameter_bundle

  ssm_parameters_with_values = [
    {
      Name  = "/${var.parameter_bundle.project}/acct/githubrunner/${var.runner_name}/role/name",
      Value = aws_iam_role.github_runner.name
    },
    {
      Name  = "/${var.parameter_bundle.project}/acct/githubrunner/${var.runner_name}/role/arn",
      Value = aws_iam_role.github_runner.arn
    },
  ]
}
