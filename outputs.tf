# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

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

output "velnor_runner_groups" {
  value       = { for name, group in var.velnor_runner_groups : name => sort(tolist(group.repositories)) }
  description = "Repositories allowed to schedule jobs on each Velnor runner group."
}
