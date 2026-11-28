# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

# Deployment environments on tailrocks/velnor-new. The release environment
# accepts deployments from branch main and from tools-v* tags.
# Live state read 2026-11-20 from repos/tailrocks/velnor-new/environments/release
# and .../deployment-branch-policies.

resource "github_repository_environment" "velnor_new_release" {
  repository        = "velnor-new"
  environment       = "release"
  can_admins_bypass = true

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "velnor_new_release_main" {
  repository     = github_repository_environment.velnor_new_release.repository
  environment    = github_repository_environment.velnor_new_release.environment
  branch_pattern = "main"
}

resource "github_repository_environment_deployment_policy" "velnor_new_release_tools_tags" {
  repository  = github_repository_environment.velnor_new_release.repository
  environment = github_repository_environment.velnor_new_release.environment
  tag_pattern = "tools-v*"
}
