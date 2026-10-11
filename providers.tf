provider "github" {
  owner = var.github_organization
  # When null, provider uses GITHUB_TOKEN / GITHUB_APP_* env (jackin standard).
  token = var.github_token != null ? var.github_token : null
}
