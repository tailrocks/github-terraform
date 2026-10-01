resource "github_actions_organization_secret" "org_secret" {
  for_each = local.org_secrets

  secret_name = each.key
  visibility  = var.secret_visibility
  value       = data.onepassword_item.org_secret[each.key].section_map[each.value.section].field_map[each.value.field].value

  # Uncomment for repo-scoped organization secret access:
  # selected_repository_ids = [for repo in data.github_repository.selected : repo.repo_id]
}
