variable "container_build_pipeline_cron_expression" {
  type        = string
  description = "The cron schedule expression for when the container should be rebuilt. Defaults to 4am MON-FRI"
  default     = "0 4 ? * MON-FRI *"
}

variable "container_sharing_account_id_list" {
  type        = list(string)
  description = "A list of additional AWS account IDs that you want to share your completed container with. Does not need to include the account in which the AMI is built as this is included by default"
  default     = []
}

variable "container_version_number" {
  type        = string
  description = "Sematic versioning version number of the container to be created. Defaults to 1.0.0"
  default     = "1.0.0"
  validation {
    condition     = can(regex("^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)$", var.container_version_number))
    error_message = "Invalid semantic version. A valid semantic version must contain three dot-separated numbers, with no leading zeros"
  }
}

variable "ecr_private_repository_account_id" {
  type        = string
  description = "The AWS account ID that hosts the private ECR registry for job docker images. Defaults to empty (i.e. no private repository required)"
  default     = ""
  validation {
    condition     = can(regex("^([0-9]{12})?$", var.ecr_private_repository_account_id))
    error_message = "Invalid account id. A valid account ID must contain 12 digits"
  }
}

variable "ecr_private_repository_name" {
  type        = string
  description = "The name of the ECR repository for job docker images. Defaults to empty (i.e. no private repository required)"
  default     = ""
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

variable "imagebuilder_ec2_extra_security_groups" {
  type        = list(string)
  description = "List of security group IDs to append to the temporary EC2 instance that will be created in order to generate the AMI. Defaults to an empty list"
  default     = []
  validation {
    condition = length([
      for sg in var.imagebuilder_ec2_extra_security_groups :
      true if can(regex("^sg-[0-9a-f]{17}$", sg))
    ]) == length(var.imagebuilder_ec2_extra_security_groups)
    error_message = "Invalid security group ID. A valid security group ID must start with 'sg-' followed by 17 alphanumeric characters."
  }
}

variable "imagebuilder_ec2_instance_type" {
  type        = string
  description = "Instance type for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to t3a.large"
  default     = "t3a.large"
}

variable "imagebuilder_log_bucket_encryption_key_arn" {
  type        = string
  description = "Encryption key ARN for the bucket that stores logs from the EC2 ImageBuilder process"
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]+:.*$", var.imagebuilder_log_bucket_encryption_key_arn))
    error_message = "Invalid Amazon Resource Name. A valid KMS ARN must start with 'arn:aws:kms', followed by a region, account ID and resource name separated by colons."
  }
}

variable "imagebuilder_log_bucket_name" {
  type        = string
  description = "Bucket that stores all logs from the EC2 ImageBuilder process"
}

variable "imagebuilder_log_bucket_path" {
  type        = string
  description = "Bucket path that stores all logs from the EC2 ImageBuilder process"
}

variable "imagebuilder_ec2_root_volume_size" {
  type        = number
  description = "Size of root volume for the temporary EC2 instance that will be created in order to generate the AMI. Defaults to 100GiB"
  default     = 100
  validation {
    condition     = var.imagebuilder_ec2_root_volume_size == floor(var.imagebuilder_ec2_root_volume_size)
    error_message = "The variable must be a whole integer"
  }
}

variable "imagebuilder_ec2_subnet_id" {
  type        = string
  description = "ID of the subnet used to host the temporary EC2 instance that will be created in order to generate the AMI"
  validation {
    condition     = can(regex("^subnet-[a-fA-F0-9]{8,}$", var.imagebuilder_ec2_subnet_id))
    error_message = "Invalid Subnet ID. A valid Subnet ID must start with 'subnet-', followed by 8 digits"
  }
}

variable "imagebuilder_ec2_terminate_on_failure" {
  type        = bool
  description = "Determines whether or not a failed AMI build cleans up its EC2 instance or leaves it around for troubleshooting. Defaults to false"
  default     = false
}

variable "imagebuilder_ec2_vpc_id" {
  type        = string
  description = "ID of the VPC used to host the temporary EC2 instance that will be created in order to generate the AMI"
  validation {
    condition     = can(regex("^vpc-[a-fA-F0-9]{8,}$", var.imagebuilder_ec2_vpc_id))
    error_message = "Invalid VPC ID. A valid VPC ID must start with 'vpc-', followed by 8 digits"
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
  description = "ARN of the IAM Policy to use as a permission boundary for the AWS ImageBuilder Role created by this module. Defaults to empty (i.e. no permission boundary required)"
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
  description = "Map of tags to be applied to all resources"
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
