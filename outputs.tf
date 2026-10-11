# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

output "managed_secrets" {
  value = {
    for name, secret in github_actions_organization_secret.org_secret :
    name => {
      visibility = secret.visibility
    }
  }

  description = "Managed org secret names and visibility. Values are intentionally omitted."
}

output "organization" {
  value = var.github_organization
}

output "managed_repositories" {
  value       = sort(tolist(module.repository_policy.managed_repositories))
  description = "Repositories under merge-policy management."
}

output "repository_settings" {
  description = "Map of repository merge and lifecycle settings"
  value       = module.repository_policy.repository_settings
}

output "required_check_contexts" {
  description = "Map of repository name to its required status-check contexts"
  value       = module.repository_policy.required_check_contexts
}

output "repository_ids" {
  description = "Map of repository name to repository ID"
  value       = module.repository_policy.repository_ids
}

output "velnor_runner_group_repositories" {
  value       = sort(tolist(var.velnor_runner_group_repositories))
  description = "Repositories allowed to schedule jobs on the velnor-trusted runner group."
}
