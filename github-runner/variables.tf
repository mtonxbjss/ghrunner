variable "module" {
  type        = string
  description = "The variable encapsulating the name of this module"
  default     = "github"
}

variable "parameter_bundle" {
  type = object(
    {
      project                             = string
      environment                         = string
      component                           = string
      group                               = string
      region                              = string
      account_ids                         = map(string)
      account_name                        = string
      default_kms_deletion_window_in_days = number
      default_tags                        = map(string)
      iam_resource_arns                   = map(string)
      target_env                          = map(any)
      pipeline_overrides                  = map(any)
      cloudwatch_options                  = map(bool)
      cloudwatch_metric_thresholds        = map(map(string))
      terraform_root_dir                  = string
    }
  )
  description = "Contains all of the default parameters needed by any module in this project"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the github runner"
  default     = "t2.micro"
}

variable "enable_spot" {
  type        = bool
  description = "run github runners as spot instances"
  default     = false
}

variable "spot_max_price" {
  type        = string
  description = "max spot price for github runners"
  default     = "0.3"
}

variable "root_volume_size" {
  type        = number
  description = "Size of root volume for the github runner manager instance"
  default     = 8
}

variable "runner_name" {
  type        = string
  description = "Name by which the github Server will know this runner"
  default     = "default-runner"
}

variable "concurrent" {
  type        = number
  description = "How many concurrent jobs the github runner can do"
  default     = 2
}

variable "tag_list" {
  type        = string
  description = "Comma-delimited list of tags that can be used to target this runner"
  default     = "default"
}

variable "main_vpc_id" {
  type        = string
  description = "ID of the VPC used to host the github Runner"
}

variable "subnet_ids" {
  type        = list(string)
  description = "ID of the subnet used to host the github Runner"
}

variable "extra_security_groups" {
  type        = list(string)
  description = "List of security group IDs to append to the runner"
  default     = []
}

variable "extra_policy_attachments" {
  type        = list(string)
  description = "List of policy ARNs to append to the runner's EC2 Instance Profile"
  default     = []
}

variable "permissions_boundary_attachment" {
  type        = string
  description = "ARN of IAM policy to use as a permissions boundary for the runner's EC2 Instance Profile"
  default     = ""
}

variable "autoscaling_min" {
  type        = number
  description = "Minimum number of instances in the autoscaling group of github Runners"
  default     = 0
}

variable "autoscaling_max" {
  type        = number
  description = "Maximum number of instances in the autoscaling group of github Runners"
  default     = 1
}

variable "autoscaling_desired" {
  type        = number
  description = "Desired number of instances in the autoscaling group of github Runners"
  default     = 1
}

variable "associate_public_ip" {
  type        = bool
  description = "Should all runner instances have public IP addresses attached (required only if you're deploying into a public subnet)"
  default     = false
}

variable "nightly_shutdown" {
  type        = bool
  description = "scale in/out the runners on a nightly basis"
  default     = false
}

variable "scale_in_time" {
  type        = string
  description = "time to scale in"
  default     = "0 20 * * *"
}

variable "scale_out_time" {
  type        = string
  description = "time to scale out"
  default     = "0 6 * * 1-5"
}

variable "runner_role" {
  type        = string
  description = "the role performed by this group of runners"
  default     = "undefined"
}

variable "github_org_url" {
  type        = string
  description = "github org url"
}

variable "github_repo_name" {
  type        = string
  description = "github repo name"
}

variable "github_server_pat_ssm_param_arn" {
  type        = string
  description = "ARN of the SSM Parameter that holds the github server personal access token"
}

variable "github_server_pat_ssm_param_name" {
  type        = string
  description = "Name of the SSM Parameter that holds the github server personal access token"
}

variable "cicd_artifacts_bucket_name" {
  type        = string
  description = "Bucket that stores all CICD artifacts for the CaaS platform"
}

variable "cicd_artifacts_bucket_key_arn" {
  type        = string
  description = "Encryption key ARN for the bucket that stores all CICD artifacts for the CaaS platform"
}

variable "docker_registry_id" {
  type        = string
  description = "ID of the ECR Docker Registry that hosts the github CI images"
}

variable "dynamic_scaling" {
  type        = bool
  description = "Controls whether runners dynamically scale up/down depending on how busy the server is"
  default     = true
}
