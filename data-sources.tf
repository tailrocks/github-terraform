data "external" "onepassword_secret" {
  for_each = local.org_secrets

  program = ["bash", "${path.module}/scripts/op_read_secret.sh"]

  query = {
    vault   = var.op_vault
    item    = each.value.item
    field   = each.value.field
    section = lookup(each.value, "section", "")
  }
}
