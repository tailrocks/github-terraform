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
  value       = sort(keys(github_repository.managed_settings))
  description = "Repositories under merge-policy management."
}

output "ruleset_repositories" {
  value       = sort(tolist(local.ruleset_repositories))
  description = "Public repositories that also receive protect-main / protect-tags rulesets."
}
