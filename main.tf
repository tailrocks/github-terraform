resource "github_actions_organization_secret" "org_secret" {
  for_each = data.external.onepassword_secret

  secret_name = each.key
  visibility  = var.secret_visibility
  value       = each.value.result.value

  # Uncomment for repo-scoped organization secret access:
  # selected_repository_ids = [for repo in data.github_repository.selected : repo.repo_id]
}
