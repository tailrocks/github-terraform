locals {
  # Fill this map with final secret names and metadata.
  # value format: item name in 1Password vault, then field key.
  # Example:
  # org_secrets = {
  #   GITHUB_WEBHOOK_SECRET = {
  #     item  = "org-credentials"
  #     field = "webhook_secret"
  #   }
  # }
  org_secrets = {}
}
