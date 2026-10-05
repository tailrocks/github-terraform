# Organization-wide policy. Actions permissions and workflow defaults match the
# live baseline (tightening waits for per-repo workflow audits). New-repository
# security defaults are intentionally hardened (detection-only, future repos).

resource "github_organization_settings" "tailrocks" {
  billing_email = "thetailrocks@gmail.com"

  name        = "tailrocks"
  description = ""
  blog        = "https://tailrocks.com"

  has_organization_projects       = true
  has_repository_projects         = true
  default_repository_permission   = "read"
  members_can_create_repositories = true

  members_can_create_public_repositories  = true
  members_can_create_private_repositories = true

  members_can_create_pages         = true
  members_can_create_public_pages  = true
  members_can_create_private_pages = true

  members_can_fork_private_repositories = false
  web_commit_signoff_required           = false

  advanced_security_enabled_for_new_repositories               = true
  dependabot_alerts_enabled_for_new_repositories               = true
  dependabot_security_updates_enabled_for_new_repositories     = true
  dependency_graph_enabled_for_new_repositories                = true
  secret_scanning_enabled_for_new_repositories                 = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
}

resource "github_actions_organization_permissions" "tailrocks" {
  enabled_repositories = "all"
  allowed_actions      = "all"
  sha_pinning_required = false
}

resource "github_actions_organization_workflow_permissions" "tailrocks" {
  organization_slug = var.github_organization

  default_workflow_permissions     = "write"
  can_approve_pull_request_reviews = false
}

resource "github_actions_runner_group" "velnor_trusted" {
  name                       = "velnor-trusted"
  visibility                 = "selected"
  allows_public_repositories = true
  restricted_to_workflows    = false
  selected_repository_ids = [
    for name in var.velnor_runner_group_repositories :
    data.github_repository.runner_group_selected[name].repo_id
  ]
}
