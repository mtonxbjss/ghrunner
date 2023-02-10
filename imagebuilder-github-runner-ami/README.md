<!-- BEGIN_TF_DOCS -->
## imagebuilder-github-runner-ami Module

### Pre-Requisites
Before deploying this module you must:
* Have a VPC with at least one subnet. The Subnets can be private or public, but they must have access to the Internet via IGW or NAT
* An S3 bucket in which to hold logs from the image building process, and (optionally) an encryption key for that bucket in KMS

### Simplest Possible Example
This is an imagebuilder pipeline to generate a GitHub Runner AMI using default values for everything.

```terraform
module "imagebuilder_github_runner_ami_simple" {
source = "git::https://github.com/mtonxbjss/ghrunner.git//imagebuilder-github-runner-ami"

ami_build_pipeline_cron_expression = "cron(0 4 ? * MON *)"
ami_version_number                 = "1.0.0"

github_runner_binary_version = "2.299.2"

imagebuilder_ec2_subnet_id = module.vpc.private_subnets[0]
imagebuilder_ec2_vpc_id    = module.vpc.vpc_id

imagebuilder_log_bucket_encryption_key_arn = aws_kms_key.cicd.arn
imagebuilder_log_bucket_name               = aws_s3_bucket.cicd.bucket
imagebuilder_log_bucket_path               = "github-runner/ami-logs/github"

iam_roles_with_admin_access_to_created_resources = [
local.identifiers.account_admin_role_arn,
]

region            = var.region
runner_account_id = var.aws_account_id
unique_prefix     = "${local.prefix}-simple"
}
```

### Full Worked Example with All Parameters Expressed
This is an imagebuilder pipeline to generate a GitHub Runner AMI overriding default values

```terraform
module "imagebuilder_github_runner_ami" {
source = "git::https://github.com/mtonxbjss/ghrunner.git//imagebuilder-github-runner-ami"

ami_build_pipeline_cron_expression = "cron(0 4 ? * MON *)"
ami_version_number                 = "1.0.0"

github_job_image_ecr_account_id      = var.aws_account_id
github_job_image_ecr_repository_name = aws_ecr_repository.terraform.name
github_runner_binary_version         = "2.299.2"

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_build_pipeline_cron_expression"></a> [ami\_build\_pipeline\_cron\_expression](#input\_ami\_build\_pipeline\_cron\_expression) | The cron schedule expression for when the AMI should be rebuilt. Defaults to 4am MON-FRI | `string` | `"cron(0 4 ? * MON-FRI *)"` | no |
| <a name="input_ami_sharing_account_id_list"></a> [ami\_sharing\_account\_id\_list](#input\_ami\_sharing\_account\_id\_list) | A list of additional AWS account IDs that you want to share your completed AMI with. Does not need to include the account in which the AMI is built as this is included by default | `list(string)` | `[]` | no |
| <a name="input_ami_version_number"></a> [ami\_version\_number](#input\_ami\_version\_number) | Sematic versioning version number of the AMI to be created. Defaults to 1.0.0 | `string` | `"1.0.0"` | no |
| <a name="input_github_job_image_ecr_account_id"></a> [github\_job\_image\_ecr\_account\_id](#input\_github\_job\_image\_ecr\_account\_id) | The AWS account ID that hosts the private ECR registry for job docker images. Defaults to empty (i.e. no private repository required) | `string` | `""` | no |
| <a name="input_github_job_image_ecr_repository_name"></a> [github\_job\_image\_ecr\_repository\_name](#input\_github\_job\_image\_ecr\_repository\_name) | The name of the ECR repository for job docker images. Defaults to empty (i.e. no private repository required) | `string` | `""` | no |
| <a name="input_github_runner_binary_bucket_encryption_key_arn"></a> [github\_runner\_binary\_bucket\_encryption\_key\_arn](#input\_github\_runner\_binary\_bucket\_encryption\_key\_arn) | Encryption key ARN for the bucket that stores the version of the GitHub Runner binary that you want to use. Defaults to empty (i.e. no encryption) | `string` | `""` | no |
| <a name="input_github_runner_binary_bucket_name"></a> [github\_runner\_binary\_bucket\_name](#input\_github\_runner\_binary\_bucket\_name) | Bucket that stores the version of the GitHub Runner binary that you want to use | `string` | `""` | no |
| <a name="input_github_runner_binary_bucket_path"></a> [github\_runner\_binary\_bucket\_path](#input\_github\_runner\_binary\_bucket\_path) | Bucket path that stores the version of the GitHub Runner binary that you want to use | `string` | `""` | no |
| <a name="input_github_runner_binary_version"></a> [github\_runner\_binary\_version](#input\_github\_runner\_binary\_version) | Version ID of the github runner binary to cache in the AMI image. No default, because GitHub doesn't support out of date versions for very long. | `string` | `""` | no |
| <a name="input_iam_roles_with_admin_access_to_created_resources"></a> [iam\_roles\_with\_admin\_access\_to\_created\_resources](#input\_iam\_roles\_with\_admin\_access\_to\_created\_resources) | List of IAM Role ARNs that should have admin access to any resources created in this module that have resource policies | `list(string)` | n/a | yes |
| <a name="input_imagebuilder_ec2_extra_security_groups"></a> [imagebuilder\_ec2\_extra\_security\_groups](#input\_imagebuilder\_ec2\_extra\_security\_groups) | List of security group IDs to append to the temporary EC2 instance that will be created in order to generate the AMI. Defaults to an empty list | `list(string)` | `[]` | no |
| <a name="input_imagebuilder_ec2_instance_type"></a> [imagebuilder\_ec2\_instance\_type](#input\_imagebuilder\_ec2\_instance\_type) | Instance type for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to t3a.large | `string` | `"t3a.large"` | no |
| <a name="input_imagebuilder_ec2_root_volume_size"></a> [imagebuilder\_ec2\_root\_volume\_size](#input\_imagebuilder\_ec2\_root\_volume\_size) | Size of root volume for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to 100GiB | `number` | `100` | no |
| <a name="input_imagebuilder_ec2_subnet_id"></a> [imagebuilder\_ec2\_subnet\_id](#input\_imagebuilder\_ec2\_subnet\_id) | ID of the subnet used to host the temporary EC2 instance that will be created in order to generate the AMI | `string` | n/a | yes |
| <a name="input_imagebuilder_ec2_terminate_on_failure"></a> [imagebuilder\_ec2\_terminate\_on\_failure](#input\_imagebuilder\_ec2\_terminate\_on\_failure) | Determines whether or not a failed AMI build cleans up its EC2 instance or leaves it around for troubleshooting. Defaults to false | `bool` | `false` | no |
| <a name="input_imagebuilder_ec2_vpc_id"></a> [imagebuilder\_ec2\_vpc\_id](#input\_imagebuilder\_ec2\_vpc\_id) | ID of the VPC used to host the temporary EC2 instance that will be created in order to generate the AMI | `string` | n/a | yes |
| <a name="input_imagebuilder_log_bucket_encryption_key_arn"></a> [imagebuilder\_log\_bucket\_encryption\_key\_arn](#input\_imagebuilder\_log\_bucket\_encryption\_key\_arn) | Encryption key ARN for the bucket that stores logs from the EC2 ImageBuilder process | `string` | n/a | yes |
| <a name="input_imagebuilder_log_bucket_name"></a> [imagebuilder\_log\_bucket\_name](#input\_imagebuilder\_log\_bucket\_name) | Bucket that stores all logs from the EC2 ImageBuilder process | `string` | n/a | yes |
| <a name="input_imagebuilder_log_bucket_path"></a> [imagebuilder\_log\_bucket\_path](#input\_imagebuilder\_log\_bucket\_path) | Bucket path that stores all logs from the EC2 ImageBuilder process | `string` | n/a | yes |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | The number of days to retain a KMS key scheduled for deletion. Defaults to 7 | `number` | `7` | no |
| <a name="input_permission_boundary_arn"></a> [permission\_boundary\_arn](#input\_permission\_boundary\_arn) | ARN of the IAM Policy to use as a permission boundary for the AWS ImageBuilder Role created by this module. Defaults to empty (i.e. no permission boundary required) | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to create resources | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Map of tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_runner_account_id"></a> [runner\_account\_id](#input\_runner\_account\_id) | The AWS account ID that should host the GitHub Runners | `string` | n/a | yes |
| <a name="input_unique_prefix"></a> [unique\_prefix](#input\_unique\_prefix) | This unique prefix will be prepended to all resource names to ensure no clashes with other resources in the same account | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_imagebuilder_image_arn_xxx"></a> [imagebuilder\_image\_arn\_xxx](#output\_imagebuilder\_image\_arn\_xxx) | ImageBuilder resulting image ARN with x.x.x placeholders to denote latest-version |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.31.0 |
## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.github_image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.github_image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_imagebuilder_component.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |
| [aws_imagebuilder_distribution_configuration.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image_pipeline.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_imagebuilder_infrastructure_configuration.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |
| [aws_kms_alias.github_imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.github_imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.github_imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ubuntu_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.github_image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_image_builder_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_github_imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
<!-- END_TF_DOCS -->