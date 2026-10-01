data "onepassword_item" "org_secret" {
  for_each = local.org_secrets

  vault = each.value.vault_uuid
  title = each.value.item
}

data "github_repository" "secret_selected" {
  for_each  = toset(flatten([for s in local.org_secrets : lookup(s, "repositories", [])]))
  full_name = "${var.github_organization}/${each.key}"
}
