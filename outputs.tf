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
