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
  value       = sort(module.repository_policy.managed_settings_repositories)
  description = "Repositories under merge-policy management."
}

output "ruleset_repositories" {
  value       = sort(module.repository_policy.full_ruleset_repositories)
  description = "Public repositories that also receive protect-main / protect-tags rulesets."
}

output "velnor_runner_group_repositories" {
  value       = sort(tolist(var.velnor_runner_group_repositories))
  description = "Repositories allowed to schedule jobs on the velnor-trusted runner group."
}
