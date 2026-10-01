# TailRocks GitHub Org OpenTofu (Private)

Manage TailRocks GitHub organization settings with OpenTofu: organization and Actions policy, repository merge policy, branch/tag rulesets, and (optionally) organization Actions secrets via 1Password.

## Scope

### Organization standard

- Organization profile and member repository/page creation policy.
- Organization-wide GitHub Actions availability and action allow policy.
- Default `GITHUB_TOKEN` workflow permissions and PR-review approval policy.
- Existing live values are adopted first. Security tightening happens only after
  every managed workflow declares its required permissions.

GitHub does not expose organization package-creation visibility or package
visibility changes through the REST API or the Terraform GitHub provider. An
organization owner must manage those settings in **Organization settings →
Packages**. Making a package public is irreversible.

### Repository standard (all managed repos)

Matches `jackin-project/jackin-github-terraform`:

| Setting | Value |
|---|---|
| Merge commits | disabled |
| Squash merge | enabled (`PR_TITLE` / `PR_BODY`) |
| Rebase merge | disabled |
| Allow update branch | enabled |
| Delete branch on merge | enabled |
| Default branch ruleset `protect-main` | active (all managed repos) |
| Tag ruleset `protect-tags` | active (all managed repos) |

All managed repositories are public, so every repo receives the full ruleset pair. (Rulesets and branch protection are unavailable to private repos on the free org plan, which is why no private repo may stay `RepoSettingsOnly` without losing merge gating.)

### Organization secrets (optional)

- Manage GitHub organization-level Actions secrets.
- Read secret material from 1Password via `external` provider + `op` CLI.
- Default visibility: `private`.

## Managed repositories

See `var.managed_repositories` in `variables.tf` (41 repos today: velnor estate + packaging + java libs + skills/marketplace + policy/iac).

## Prerequisites

- OpenTofu 1.7+ (or `mise` — see tasks below)
- GitHub token with org admin + repo admin scopes, stored in 1Password at `op://tailrocks/GitHub/tokens/tofu`
- For secrets: `op` CLI + `jq`, and authenticated 1Password (service account preferred in CI)

## Configure

```sh
cp terraform.tfvars.example terraform.tfvars   # optional overrides
```

Run tofu through the mise tasks so the GitHub token is injected from 1Password (never exported by hand):

```sh
mise run tofu:plan -- <plan args>
mise run tofu:apply -- <apply args>
```

Optional secrets map in `locals.tf`:

```hcl
locals {
  org_secrets = {
    NPM_TOKEN = {
      item  = "org-credentials"
      field = "npm_token"
    }
  }
}
```

## Bootstrap / apply

```sh
cd /Users/donbeave/Projects/tailrocks/github-terraform
tofu init
tofu plan
tofu apply
```

Existing repos are imported via `imports.tf` on first apply.

## Required status checks

Fill `repo_required_status_checks` in `variables.tf` when aggregator check names are stable per repo (bare check-run name, not `workflow / job` UI label). Empty map = rulesets without required checks.

## Notes

- Provider 6.x org secrets use `value` for secret text.
- `lifecycle.prevent_destroy` on managed repos stops IaC deletion only — UI deletion still possible for owners.
- Never commit `*.tfstate`, `*.tfvars`, or tokens.
