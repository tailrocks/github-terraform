# Optional helper for selected repository visibility.
# Populate this map when you want visibility="selected":
#
# data "github_repository" "selected" {
#   for_each  = toset(["repo-a", "repo-b"])
#   full_name = "${var.github_organization}/${each.key}"
# }
