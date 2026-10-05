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
  value       = sort(module.retained_policy_exceptions.managed_settings_repositories)
  description = "TailRocks repositories retained as local policy exceptions."
}

output "ruleset_repositories" {
  value       = sort(module.retained_policy_exceptions.full_ruleset_repositories)
  description = "Repositories receiving local protect-main / protect-tags rulesets."
}

output "velnor_runner_group_repositories" {
  value       = sort(tolist(var.velnor_runner_group_repositories))
  description = "Repositories allowed to schedule jobs on the velnor-trusted runner group."
}
