data "onepassword_item" "org_secret" {
  for_each = local.org_secrets

  vault = each.value.vault_uuid
  title = each.value.item
}
