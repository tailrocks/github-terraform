resource "github_actions_organization_secret" "org_secret" {
  for_each = local.org_secrets

  secret_name = each.key
  visibility  = lookup(each.value, "visibility", var.secret_visibility)
  value       = data.onepassword_item.org_secret[each.key].section_map[each.value.section].field_map[each.value.field].value

  selected_repository_ids = lookup(each.value, "visibility", var.secret_visibility) == "selected" ? [for r in lookup(each.value, "repositories", []) : data.github_repository.secret_selected[r].repo_id] : null
}
