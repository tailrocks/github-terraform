locals {
  # Fill this map with final secret names and metadata.
  # value format: vault UUID, item title, section label, field label.
  # Vault UUID: op vault get NAME --format json | jq -r .id
  # Example:
  # org_secrets = {
  #   GITHUB_WEBHOOK_SECRET = {
  #     vault_uuid = "xlm7pn5y6d3nfya5xy2os3vtoq"
  #     item       = "org-credentials"
  #     section    = "tokens"
  #     field      = "webhook_secret"
  #   }
  # }
  org_secrets = {
    # CARGO_REGISTRY_TOKEN removed 2026-10-01: termpane 0.1.0 published;
    # crates.io Trusted Publisher (tailrocks/termpane, release.yml, release)
    # replaces the bootstrap token path. No org secrets remain.
  }
}
