#
# Provider
#
provider "tfe" {
  version = "~> 0.15.0"
  token   = var.tfe_token
}
#
# Terraform Cloud Workspace
#
resource "tfe_workspace" "development" {
  name              = "${var.git_repo}-${local.target_branch}"
  organization      = var.tfc_org
  auto_apply        = (local.target_branch != "production" && local.target_branch != "test")
  operations        = true
  queue_all_runs    = false # set in order to avoid variables race condition when creating the workspace
  terraform_version = "0.12.26"
  vcs_repo {
      identifier         = "${var.git_org}/${var.git_repo}"
      branch             = local.target_branch
      ingress_submodules = false
      oauth_token_id     = var.github_oauth_token
  }
}
# Policiies removed as they are not part of Terraform Cloud Free Plan
#
#
# Terraform Cloud Workspace Variables
#
resource "tfe_variable" "tfcvars" {
  for_each     = local.tfcvars
  key          = each.key
  value        = each.value.value
  category     = each.value.category # "terraform" or "env"
  hcl          = each.value.hcl
  sensitive    = each.value.sensitive
  workspace_id = tfe_workspace.development.id
  description  = each.value.description
}