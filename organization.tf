# Organization-wide policy. Values intentionally match the live baseline so
# importing these resources does not combine adoption with a policy change.

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

  advanced_security_enabled_for_new_repositories               = false
  dependabot_alerts_enabled_for_new_repositories               = false
  dependabot_security_updates_enabled_for_new_repositories     = false
  dependency_graph_enabled_for_new_repositories                = false
  secret_scanning_enabled_for_new_repositories                 = false
  secret_scanning_push_protection_enabled_for_new_repositories = false
}

resource "github_actions_organization_permissions" "tailrocks" {
  enabled_repositories = "all"
  allowed_actions      = "all"
  sha_pinning_required = false
}

resource "github_actions_organization_workflow_permissions" "tailrocks" {
  organization_slug = var.github_organization

  default_workflow_permissions     = "write"
  can_approve_pull_request_reviews = true
}
