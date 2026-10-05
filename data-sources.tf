data "onepassword_item" "org_secret" {
  for_each = local.org_secrets

  vault = each.value.vault_uuid
  title = each.value.item
}

data "github_repository" "secret_selected" {
  for_each  = toset(flatten([for s in local.org_secrets : lookup(s, "repositories", [])]))
  full_name = "${var.github_organization}/${each.key}"
}

# Runner-group membership remains organization-scoped even after repository
# policy ownership moves to the central control-plane root.
data "github_repository" "runner_group_selected" {
  for_each  = var.velnor_runner_group_repositories
  full_name = "${var.github_organization}/${each.value}"
}
