
variable "cicd_artifacts_bucket_name" {
  type        = string
  description = "Bucket that stores all CICD artifacts for the pipeline(s)"
  default     = ""
}

variable "cicd_artifacts_bucket_key_arn" {
  type        = string
  description = "Encryption key ARN for the bucket that stores all CICD artifacts for the pipeline(s)"
  default     = ""
  validation {
    condition     = can(regex("^(arn:aws:kms:[a-z0-9-]+:[0-9]+:.*)?$", var.cicd_artifacts_bucket_key_arn))
    error_message = "Invalid Amazon Resource Name. A valid KMS ARN must start with 'arn:aws:kms', followed by a region, account ID and resource name separated by colons."
  }
}

variable "cloudwatch_metric_cloud_init_failure_name" {
  type        = string
  description = "The name to give the metric that tracks Cloud Init failures on GitHub Runner EC2 instances. Defaults to CloudInitFailureCount"
  default     = "CloudInitFailureCount"
}

variable "cloudwatch_metric_github_runner_failure_name" {
  type        = string
  description = "The name to give the metric that tracks GitHub Connectivity failures on GitHub Runner EC2 instances. Defaults to GithubRunnerFailureCount"
  default     = "GithubRunnerFailureCount"
}

variable "ec2_associate_public_ip_address" {
  type        = bool
  description = "Should all runner instances have public IP addresses attached (required only if you're deploying into a public subnet)"
  default     = false
}

variable "ec2_autoscaling_desired_instances" {
  type        = number
  description = "Desired number of instances in the autoscaling group of github Runners"
  default     = 1
  validation {
    condition     = var.ec2_autoscaling_desired_instances == floor(var.ec2_autoscaling_desired_instances)
    error_message = "The variable must be a whole integer"
  }
}

variable "ec2_autoscaling_maximum_instances" {
  type        = number
  description = "Maximum number of instances in the autoscaling group of github Runners"
  default     = 1
  validation {
    condition     = var.ec2_autoscaling_maximum_instances == floor(var.ec2_autoscaling_maximum_instances)
    error_message = "The variable must be a whole integer"
  }
}

variable "ec2_autoscaling_minimum_instances" {
  type        = number
  description = "Minimum number of instances in the autoscaling group of github Runners"
  default     = 0
  validation {
    condition     = var.ec2_autoscaling_minimum_instances == floor(var.ec2_autoscaling_minimum_instances)
    error_message = "The variable must be a whole integer"
  }
}

variable "ec2_dynamic_scaling_enabled" {
  type        = bool
  description = "Controls whether GitHub runners dynamically scale up/down depending on how busy the server is"
  default     = false
}

variable "ec2_dynamic_scaling_metric_collection_cron_expression" {
  type        = string
  description = "Cron expression that dictates how often to run the cron expression that gathers github runner utilisation metrics. Default is every minute between 0700-1959 Monday-Friday UTC (0800-2059 during BST)"
  default     = "0/1 07-19 ? * MON-FRI *"
}

variable "ec2_extra_security_groups" {
  type        = list(string)
  description = "List of security group IDs to append to the EC2 instances for running GitHub jobs. Defaults to an empty list"
  default     = []
  validation {
    condition = length([
      for sg in var.ec2_extra_security_groups :
      true if can(regex("^sg-[0-9a-f]{17}$", sg))
    ]) == length(var.ec2_extra_security_groups)
    error_message = "Invalid security group ID. A valid security group ID must start with 'sg-' followed by 17 alphanumeric characters."
  }
}

variable "ec2_github_runner_name" {
  type        = string
  description = "Name by which the github Server will know this runner"
  default     = "default"
}

variable "ec2_github_runner_tag_list" {
  type        = string
  description = "Comma-delimited list of tags that can be used to target this runner"
  default     = "default"
}

variable "ec2_iam_role_extra_policy_attachments" {
  type        = list(string)
  description = "List of policy ARNs to append to the runner's EC2 Instance Profile. Use this to give your runner permission to deploy things in your accounts."
  default     = []
  validation {
    condition = length([
      for arn in var.ec2_iam_role_extra_policy_attachments :
      true if can(regex("^arn:aws:iam::[0-9]+:.*$", arn))
    ]) == length(var.ec2_iam_role_extra_policy_attachments)
    error_message = "Invalid Amazon Resource Name. A valid IAM Policy ARN must start with 'arn:aws:iam', followed by a region, account ID and resource name separated by colons."
  }
}

variable "ec2_imagebuilder_image_arn" {
  type        = string
  description = "ARN of the AWS ImageBuilder image that results from the GitHub AMI creation pipeline"
  validation {
    condition     = can(regex("^arn:aws:imagebuilder:[a-z0-9-]+:[0-9]+:.*$", var.ec2_imagebuilder_image_arn))
    error_message = "Invalid Amazon Resource Name. A valid ImageBuilder Image ARN must start with 'arn:aws:imagebuilder', followed by a region, account ID and resource name separated by colons."
  }
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance type for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to t3a.large"
  default     = "t3a.large"
}

variable "ec2_maximum_concurrent_github_jobs" {
  type        = number
  description = "How many concurrent jobs the github runner can do"
  default     = 2
  validation {
    condition     = var.ec2_maximum_concurrent_github_jobs == floor(var.ec2_maximum_concurrent_github_jobs)
    error_message = "The variable must be a whole integer"
  }
}

variable "ec2_nightly_shutdown_enabled" {
  type        = bool
  description = "scale in/out the runners on a nightly basis"
  default     = false
}

variable "ec2_nightly_shutdown_scale_in_time" {
  type        = string
  description = "time to scale in"
  default     = "0 20 * * *"
}

variable "ec2_nightly_shutdown_scale_out_time" {
  type        = string
  description = "time to scale out"
  default     = "0 6 * * 1-5"
}

variable "ec2_root_volume_size" {
  type        = number
  description = "Size of root volume for the EC2 instances for running GitHub jobs. Defaults to 100GiB"
  default     = 100
  validation {
    condition     = var.ec2_root_volume_size == floor(var.ec2_root_volume_size)
    error_message = "The variable must be a whole integer"
  }
}

variable "ec2_runner_role_tag" {
  type        = string
  description = "Adds a new Role tag to each runner with this value, to indicate the functional role performed by particular group of runners"
  default     = "general"
}

variable "ec2_spot_instances_max_price" {
  type        = string
  description = "max spot price for github runners"
  default     = "0.3"
}

variable "ec2_spot_instances_preferred" {
  type        = bool
  description = "run github runners as spot instances"
  default     = false
}

variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of IDs of the subnets used to host the EC2 instances for running GitHub jobs"
  validation {
    condition = length([
      for arn in var.ec2_subnet_ids :
      true if can(regex("^subnet-[a-fA-F0-9]{8,}$", arn))
    ]) == length(var.ec2_subnet_ids)
    error_message = "Invalid Subnet ID. A valid Subnet ID must start with 'subnet-', followed by at least 8 digits"
  }
}

variable "ec2_terraform_deployment_roles" {
  type        = list(string)
  description = "List of deployment role ARNs that can be assumed by the runner in order to execute Terraform commands"
  default     = []
  validation {
    condition = length([
      for arn in var.ec2_terraform_deployment_roles :
      true if can(regex("^arn:aws:iam::[0-9]+:.*$", arn))
    ]) == length(var.ec2_terraform_deployment_roles)
    error_message = "Invalid Amazon Resource Name. A valid IAM Role ARN must start with 'arn:aws:iam', followed by a region, account ID and resource name separated by colons."
  }
}

variable "ec2_vpc_id" {
  type        = string
  description = "ID of the VPC used to host the EC2 instances for running GitHub jobs"
  validation {
    condition     = can(regex("^vpc-[a-fA-F0-9]{8,}$", var.ec2_vpc_id))
    error_message = "Invalid VPC ID. A valid VPC ID must start with 'vpc-', followed by 8 digits"
  }
}

variable "github_job_image_ecr_account" {
  type        = string
  description = "Account ID containing the ECR Docker Registry that hosts the images used for GitHub Actions jobs. Used so that the runner can proactively log into that registry. Default is empty (i.e. no docker images required)"
  default     = ""
  validation {
    condition     = can(regex("^([0-9]{12})?$", var.github_job_image_ecr_account))
    error_message = "Invalid account id. A valid account ID must contain 12 digits"
  }
}

variable "github_organization_url" {
  type        = string
  description = "The full https URL of the GitHub Organization or Owner, not including project name"
  validation {
    condition     = can(regex("^https:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)$", var.github_organization_url))
    error_message = "Invalid https:// url"
  }
}

variable "github_repository_name" {
  type        = string
  description = "The name of the GitHub Repository to which these runners should register"
}

variable "iam_roles_with_admin_access_to_created_resources" {
  type        = list(string)
  description = "List of IAM Role ARNs that should have admin access to any resources created in this module that have resource policies"
  validation {
    condition = length([
      for arn in var.iam_roles_with_admin_access_to_created_resources :
      true if can(regex("^arn:aws:iam::[0-9]+:.*$", arn))
    ]) == length(var.iam_roles_with_admin_access_to_created_resources)
    error_message = "Invalid Amazon Resource Name. A valid IAM Role ARN must start with 'arn:aws:iam', followed by a region, account ID and resource name separated by colons."
  }
}

variable "iam_roles_with_read_access_to_created_resources" {
  type        = list(string)
  description = "List of IAM Role ARNs that should have read access to any resources created in this module that have resource policies"
  default     = []
  validation {
    condition = length([
      for arn in var.iam_roles_with_read_access_to_created_resources :
      true if can(regex("^arn:aws:iam::[0-9]+:.*$", arn))
    ]) == length(var.iam_roles_with_read_access_to_created_resources)
    error_message = "Invalid Amazon Resource Name. A valid IAM Role ARN must start with 'arn:aws:iam', followed by a region, account ID and resource name separated by colons."
  }
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "The number of days to retain a KMS key scheduled for deletion. Defaults to 7"
  default     = 7
  validation {
    condition     = var.kms_deletion_window_in_days == floor(var.kms_deletion_window_in_days)
    error_message = "The variable must be a whole integer"
  }
}

variable "permission_boundary_arn" {
  type        = string
  description = "ARN of the IAM Policy to use as a permission boundary for the EC2 IAM Role created by this module. Defaults to empty (i.e. no permission boundary required)"
  default     = ""
  validation {
    condition     = can(regex("^(arn:aws:iam::[0-9]+:.*)?$", var.permission_boundary_arn))
    error_message = "Invalid Amazon Resource Name. A valid IAM Policy ARN must start with 'arn:aws:iam', followed by a region, account ID and resource name separated by colons."
  }
}

variable "region" {
  type        = string
  description = "The AWS region in which to create resources"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+-[0-9]+$", var.region))
    error_message = "Invalid Amazon Region ID"
  }
}

variable "resource_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources. Don't include provider tags in here or it will cause continual re-plans of tagged resources"
  default     = {}
}

variable "runner_account_id" {
  type        = string
  description = "The AWS account ID that should host the GitHub Runners"
  validation {
    condition     = can(regex("^[0-9]{12}$", var.runner_account_id))
    error_message = "Invalid account id. A valid account ID must contain 12 digits"
  }
}

variable "unique_prefix" {
  type        = string
  description = "This unique prefix will be prepended to all resource names to ensure no clashes with other resources in the same account"
}
