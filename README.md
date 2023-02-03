# ghrunner
GitHub Actions Runner Terraform Modules

Docs are to be written, but in the short term here's some example usage listings for each resource type: 

## imagebuilder-terraform-container

```terraform

module "imagebuilder_terraform_container" {
  source = "git::https://github.com/mtonxbjss/ghrunner.git//imagebuilder-terraform-container"

  container_build_pipeline_cron_expression = "cron(0 4 ? * MON *)"
  container_version_number                 = "1.0.0"

  ecr_private_repository_account_id = var.aws_account_id
  ecr_private_repository_name       = aws_ecr_repository.terraform.name

  imagebuilder_ec2_instance_type         = "t3a.large"
  imagebuilder_ec2_root_volume_size      = 100
  imagebuilder_ec2_subnet_id             = module.vpc.private_subnets[0]
  imagebuilder_ec2_terminate_on_failure  = false
  imagebuilder_ec2_vpc_id                = module.vpc.vpc_id

  imagebuilder_log_bucket_encryption_key_arn = aws_kms_key.cicd.arn
  imagebuilder_log_bucket_name               = aws_s3_bucket.cicd.bucket
  imagebuilder_log_bucket_path               = "github-runner/container-logs/terraform"

  iam_roles_with_admin_access_to_created_resources = [
    local.identifiers.app_deployer_role_arn,
    local.identifiers.account_admin_role_arn,
  ]

  permission_boundary_arn = aws_iam_policy.permissions_boundary.arn
  region                  = var.region
  runner_account_id       = var.aws_account_id
  unique_prefix           = local.prefix
}

```

## imagebuilder-github-runner-ami

```terraform

module "imagebuilder_github_runner_ami" {
  source = "git::https://github.com/mtonxbjss/ghrunner.git//imagebuilder-github-runner-ami"

  ami_build_pipeline_cron_expression = "cron(0 4 ? * MON *)"
  ami_version_number                 = "1.0.0"

  ecr_private_repository_account_id = var.aws_account_id
  ecr_private_repository_name       = aws_ecr_repository.terraform.name

  github_job_image_ecr_account = var.aws_account_id
  github_runner_binary_version = "2.299.2"

  imagebuilder_ec2_instance_type        = "t3a.large"
  imagebuilder_ec2_root_volume_size     = 100
  imagebuilder_ec2_subnet_id            = module.vpc.private_subnets[0]
  imagebuilder_ec2_terminate_on_failure = false
  imagebuilder_ec2_vpc_id               = module.vpc.vpc_id

  imagebuilder_log_bucket_encryption_key_arn = aws_kms_key.cicd.arn
  imagebuilder_log_bucket_name               = aws_s3_bucket.cicd.bucket
  imagebuilder_log_bucket_path               = "github-runner/ami-logs/github"

  iam_roles_with_admin_access_to_created_resources = [
    local.identifiers.app_deployer_role_arn,
    local.identifiers.account_admin_role_arn,
  ]

  permission_boundary_arn = aws_iam_policy.permissions_boundary.arn
  region                  = var.region
  runner_account_id       = var.aws_account_id
  unique_prefix           = local.prefix
}

```

## autoscaling-github-runners

```terraform

module "autoscaling_github_runners" {
  source = "git::https://github.com/mtonxbjss/ghrunner.git//autoscaling-github-runners"

  cicd_artifacts_bucket_name    = aws_s3_bucket.cicd.bucket
  cicd_artifacts_bucket_key_arn = aws_kms_key.cicd.arn

  ec2_autoscaling_desired_instances = 1
  ec2_autoscaling_maximum_instances = 10
  ec2_autoscaling_minimum_instances = 1
  ec2_dynamic_scaling_enabled       = true
  ec2_github_runner_name            = "general"
  ec2_github_runner_tag_list        = "techtest"

  ec2_iam_role_extra_policy_attachments = [
    aws_iam_policy.modify_state.arn,
    aws_iam_policy.deploy_application.arn,
  ]

  ec2_imagebuilder_image_arn          = module.imagebuilder_github_runner_ami.imagebuilder_image_arn_xxx
  ec2_instance_type                   = "t3a.large"
  ec2_maximum_concurrent_github_jobs  = 3
  ec2_nightly_shutdown_enabled        = true
  ec2_nightly_shutdown_scale_in_time  = "0 19 * * *"
  ec2_nightly_shutdown_scale_out_time = "0 8 * * MON-FRI"
  ec2_root_volume_size                = 100
  ec2_runner_role_tag                 = "TechTest GitHub Actions jobs"
  ec2_spot_instances_max_price        = 0.5
  ec2_spot_instances_preferred        = true
  ec2_subnet_ids                      = module.vpc.private_subnets

  ec2_terraform_deployment_roles = [
    local.identifiers.app_deployer_role_arn,
  ]

  ec2_vpc_id = module.vpc.vpc_id

  github_job_image_ecr_account = var.aws_account_id
  github_organization_url      = "https://github.com/bjsscloud"
  github_repository_name       = "bjss-careers-aws-dev"

  iam_roles_with_admin_access_to_created_resources = [
    local.identifiers.app_deployer_role_arn,
    local.identifiers.account_admin_role_arn,
  ]

  permission_boundary_arn = aws_iam_policy.permissions_boundary.arn
  region                  = var.region
  runner_account_id       = var.aws_account_id
  unique_prefix           = local.prefix
}

```
