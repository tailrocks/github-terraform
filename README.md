# TailRocks GitHub Org OpenTofu (Private)

Baseline repository for managing TailRocks GitHub Organization secrets with OpenTofu and 1Password CLI.

## Scope

- Manage GitHub organization-level Actions secrets.
- Read secret material from 1Password via `external` provider + `op` CLI.
- Start with `private` visibility by default.

## Prerequisites

- OpenTofu 1.7+
- `op` CLI installed and authenticated (service account preferred in CI)
- `jq`
- GitHub API token with organization admin scope for Actions secrets

## 1Password CLI setup (CI)

Use service account token for non-interactive runs:

```sh
export OP_SERVICE_ACCOUNT_TOKEN="..."
```

Then verify:

```sh
op account list
```

## Configure secrets map

Populate `locals.org_secrets` in `locals.tf` with one entry per GitHub secret:

```hcl
locals {
  org_secrets = {
    GITHUB_WEBHOOK_SECRET = {
      item  = "org-credentials"
      field = "webhook_secret"
    }
    NPM_TOKEN = {
      item  = "org-credentials"
      field = "npm_token"
    }
  }
}
```

Key naming convention:
- secret name in map key -> GitHub secret name
- `item` -> 1Password item name in `var.op_vault`
- `field` -> 1Password field key to read

## Configure variables

Copy example vars:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Then set runtime secrets securely via env:

```sh
export TF_VAR_github_token="<org github token>"
```

## Bootstrap

```sh
cd /Users/donbeave/Projects/tailrocks/github-terraform
tofu init
tofu plan
tofu apply
```

## Notes

- In provider 6.x for GitHub, this module uses `value` for secret text.
- This repo is intentionally state-light in secret examples until TailRocks secrets are provided.
