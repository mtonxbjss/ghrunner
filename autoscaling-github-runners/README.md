<!-- BEGIN_TF_DOCS -->
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cicd_artifacts_bucket_key_arn"></a> [cicd\_artifacts\_bucket\_key\_arn](#input\_cicd\_artifacts\_bucket\_key\_arn) | Encryption key ARN for the bucket that stores all CICD artifacts for the CaaS platform | `string` | n/a | yes |
| <a name="input_cicd_artifacts_bucket_name"></a> [cicd\_artifacts\_bucket\_name](#input\_cicd\_artifacts\_bucket\_name) | Bucket that stores all CICD artifacts for the CaaS platform | `string` | n/a | yes |
| <a name="input_cloudwatch_metric_cloud_init_failure_name"></a> [cloudwatch\_metric\_cloud\_init\_failure\_name](#input\_cloudwatch\_metric\_cloud\_init\_failure\_name) | The name to give the metric that tracks Cloud Init failures on GitHub Runner EC2 instances. Defaults to CloudInitFailureCount | `string` | `"CloudInitFailureCount"` | no |
| <a name="input_cloudwatch_metric_github_runner_failure_name"></a> [cloudwatch\_metric\_github\_runner\_failure\_name](#input\_cloudwatch\_metric\_github\_runner\_failure\_name) | The name to give the metric that tracks GitHub Connectivity failures on GitHub Runner EC2 instances. Defaults to GithubRunnerFailureCount | `string` | `"GithubRunnerFailureCount"` | no |
| <a name="input_ec2_associate_public_ip_address"></a> [ec2\_associate\_public\_ip\_address](#input\_ec2\_associate\_public\_ip\_address) | Should all runner instances have public IP addresses attached (required only if you're deploying into a public subnet) | `bool` | `false` | no |
| <a name="input_ec2_autoscaling_desired_instances"></a> [ec2\_autoscaling\_desired\_instances](#input\_ec2\_autoscaling\_desired\_instances) | Desired number of instances in the autoscaling group of github Runners | `number` | `1` | no |
| <a name="input_ec2_autoscaling_maximum_instances"></a> [ec2\_autoscaling\_maximum\_instances](#input\_ec2\_autoscaling\_maximum\_instances) | Maximum number of instances in the autoscaling group of github Runners | `number` | `1` | no |
| <a name="input_ec2_autoscaling_minimum_instances"></a> [ec2\_autoscaling\_minimum\_instances](#input\_ec2\_autoscaling\_minimum\_instances) | Minimum number of instances in the autoscaling group of github Runners | `number` | `0` | no |
| <a name="input_ec2_dynamic_scaling_enabled"></a> [ec2\_dynamic\_scaling\_enabled](#input\_ec2\_dynamic\_scaling\_enabled) | Controls whether GitHub runners dynamically scale up/down depending on how busy the server is | `bool` | `true` | no |
| <a name="input_ec2_dynamic_scaling_metric_collection_cron_expression"></a> [ec2\_dynamic\_scaling\_metric\_collection\_cron\_expression](#input\_ec2\_dynamic\_scaling\_metric\_collection\_cron\_expression) | Cron expression that dictates how often to run the cron expression that gathers github runner utilisation metrics. Default is every minute between 0700-1959 Monday-Friday UTC (0800-2059 during BST) | `string` | `"0/1 07-19 ? * MON-FRI *"` | no |
| <a name="input_ec2_extra_security_groups"></a> [ec2\_extra\_security\_groups](#input\_ec2\_extra\_security\_groups) | List of security group IDs to append to the EC2 instances for running GitHub jobs. Defaults to an empty list | `list(string)` | `[]` | no |
| <a name="input_ec2_github_runner_name"></a> [ec2\_github\_runner\_name](#input\_ec2\_github\_runner\_name) | Name by which the github Server will know this runner | `string` | `"default"` | no |
| <a name="input_ec2_github_runner_tag_list"></a> [ec2\_github\_runner\_tag\_list](#input\_ec2\_github\_runner\_tag\_list) | Comma-delimited list of tags that can be used to target this runner | `string` | `"default"` | no |
| <a name="input_ec2_iam_role_extra_policy_attachments"></a> [ec2\_iam\_role\_extra\_policy\_attachments](#input\_ec2\_iam\_role\_extra\_policy\_attachments) | List of policy ARNs to append to the runner's EC2 Instance Profile. Use this to give your runner permission to deploy things in your accounts. | `list(string)` | `[]` | no |
| <a name="input_ec2_imagebuilder_image_arn"></a> [ec2\_imagebuilder\_image\_arn](#input\_ec2\_imagebuilder\_image\_arn) | ARN of the AWS ImageBuilder image that results from the GitHub AMI creation pipeline | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Instance type for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to t3a.large | `string` | `"t3a.large"` | no |
| <a name="input_ec2_maximum_concurrent_github_jobs"></a> [ec2\_maximum\_concurrent\_github\_jobs](#input\_ec2\_maximum\_concurrent\_github\_jobs) | How many concurrent jobs the github runner can do | `number` | `2` | no |
| <a name="input_ec2_nightly_shutdown_enabled"></a> [ec2\_nightly\_shutdown\_enabled](#input\_ec2\_nightly\_shutdown\_enabled) | scale in/out the runners on a nightly basis | `bool` | `false` | no |
| <a name="input_ec2_nightly_shutdown_scale_in_time"></a> [ec2\_nightly\_shutdown\_scale\_in\_time](#input\_ec2\_nightly\_shutdown\_scale\_in\_time) | time to scale in | `string` | `"0 20 * * *"` | no |
| <a name="input_ec2_nightly_shutdown_scale_out_time"></a> [ec2\_nightly\_shutdown\_scale\_out\_time](#input\_ec2\_nightly\_shutdown\_scale\_out\_time) | time to scale out | `string` | `"0 6 * * 1-5"` | no |
| <a name="input_ec2_root_volume_size"></a> [ec2\_root\_volume\_size](#input\_ec2\_root\_volume\_size) | Size of root volume for the EC2 instances for running GitHub jobs. Defaults to 100GiB | `number` | `100` | no |
| <a name="input_ec2_runner_role_tag"></a> [ec2\_runner\_role\_tag](#input\_ec2\_runner\_role\_tag) | Adds a new Role tag to each runner with this value, to indicate the functional role performed by particular group of runners | `string` | `"general"` | no |
| <a name="input_ec2_spot_instances_max_price"></a> [ec2\_spot\_instances\_max\_price](#input\_ec2\_spot\_instances\_max\_price) | max spot price for github runners | `string` | `"0.3"` | no |
| <a name="input_ec2_spot_instances_preferred"></a> [ec2\_spot\_instances\_preferred](#input\_ec2\_spot\_instances\_preferred) | run github runners as spot instances | `bool` | `false` | no |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | List of IDs of the subnets used to host the EC2 instances for running GitHub jobs | `list(string)` | n/a | yes |
| <a name="input_ec2_terraform_deployment_roles"></a> [ec2\_terraform\_deployment\_roles](#input\_ec2\_terraform\_deployment\_roles) | List of deployment role ARNs that can be assumed by the runner in order to execute Terraform commands | `list(string)` | `[]` | no |
| <a name="input_ec2_vpc_id"></a> [ec2\_vpc\_id](#input\_ec2\_vpc\_id) | ID of the VPC used to host the EC2 instances for running GitHub jobs | `string` | n/a | yes |
| <a name="input_github_job_image_ecr_account"></a> [github\_job\_image\_ecr\_account](#input\_github\_job\_image\_ecr\_account) | Account ID containing the ECR Docker Registry that hosts the images used for GitHub Actions jobs. Used so that the runner can proactively log into that registry. Default is empty (i.e. no docker images required) | `string` | `""` | no |
| <a name="input_github_organization_url"></a> [github\_organization\_url](#input\_github\_organization\_url) | The full https URL of the GitHub Organization or Owner, not including project name | `string` | n/a | yes |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | The name of the GitHub Repository to which these runners should register | `string` | n/a | yes |
| <a name="input_iam_roles_with_admin_access_to_created_resources"></a> [iam\_roles\_with\_admin\_access\_to\_created\_resources](#input\_iam\_roles\_with\_admin\_access\_to\_created\_resources) | List of IAM Role ARNs that should have admin access to any resources created in this module that have resource policies | `list(string)` | `[]` | no |
| <a name="input_iam_roles_with_read_access_to_created_resources"></a> [iam\_roles\_with\_read\_access\_to\_created\_resources](#input\_iam\_roles\_with\_read\_access\_to\_created\_resources) | List of IAM Role ARNs that should have read access to any resources created in this module that have resource policies | `list(string)` | `[]` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | The number of days to retain a KMS key scheduled for deletion. Defaults to 7 | `number` | `7` | no |
| <a name="input_permission_boundary_arn"></a> [permission\_boundary\_arn](#input\_permission\_boundary\_arn) | ARN of the IAM Policy to use as a permission boundary for the EC2 IAM Role created by this module. Defaults to empty (i.e. no permission boundary required) | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to create resources | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Map of tags to be applied to all resources. Don't include provider tags in here or it will cause continual re-plans of tagged resources | `map(string)` | `{}` | no |
| <a name="input_runner_account_id"></a> [runner\_account\_id](#input\_runner\_account\_id) | The AWS account ID that should host the GitHub Runners | `string` | n/a | yes |
| <a name="input_unique_prefix"></a> [unique\_prefix](#input\_unique\_prefix) | This unique prefix will be prepended to all resource names to ensure no clashes with other resources in the same account | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_scaling_group_arn"></a> [auto\_scaling\_group\_arn](#output\_auto\_scaling\_group\_arn) | n/a |
| <a name="output_auto_scaling_group_name"></a> [auto\_scaling\_group\_name](#output\_auto\_scaling\_group\_name) | n/a |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | n/a |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | n/a |
| <a name="output_instance_role_arn"></a> [instance\_role\_arn](#output\_instance\_role\_arn) | n/a |
| <a name="output_instance_role_id"></a> [instance\_role\_id](#output\_instance\_role\_id) | n/a |
| <a name="output_instance_role_name"></a> [instance\_role\_name](#output\_instance\_role\_name) | n/a |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | n/a |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | n/a |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | n/a |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.31.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >=2.2.0 |
## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.dynamic_scale_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.dynamic_scale_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.scale_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_schedule.scale_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_cloudwatch_dashboard.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_event_rule.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.cloudinit_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.cloudinit_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.dynamic_scale_in_free_capacity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.dynamic_scale_out_free_capacity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_runner_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.trigger_github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.trigger_github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_runner_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_runner_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.trigger_github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.github_metrics_from_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_launch_template.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_secretsmanager_secret.github_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_policy.github_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy) | resource |
| [aws_secretsmanager_secret_version.github_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [archive_file.github_metrics_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.ubuntu_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ec2_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_metrics_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_runner_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_github_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_github_metrics_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_imagebuilder_image.github_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/imagebuilder_image) | data source |
| [cloudinit_config.github_runner](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
<!-- END_TF_DOCS -->