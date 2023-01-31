data "cloudinit_config" "github_runner" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = templatefile(
      "${path.module}/templates/cloudinit_config.tmpl.yaml",
      {
        CLOUDWATCH_AGENT_CONFIG = local.cloudwatch_agent_config
        TF_ASG_NAME             = "${local.csi}-${var.runner_name}"
        CSI                     = local.csi
        REGION                  = var.parameter_bundle.region
        PROJECT                 = var.parameter_bundle.project
        RUNNER_NAME             = var.runner_name
        TAG_LIST                = var.tag_list
        CONCURRENT              = var.concurrent
        MANAGEMENT_ACCOUNT_ID   = var.parameter_bundle.account_ids["caas-pl-mgmt"]
        CICD_ARTIFACTS_BUCKET   = var.cicd_artifacts_bucket_name
        DOCKER_REGISTRY_ID      = var.docker_registry_id
        PAT_PATH                = var.github_server_pat_ssm_param_name
        GITHUB_ORG_URL          = var.github_org_url
        GITHUB_REPO_NAME        = var.github_repo_name
      }
    )
  }
}
