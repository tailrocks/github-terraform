# TailRocks GitHub Org OpenTofu (Public)

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
| Allow update branch | disabled |
| Delete branch on merge | enabled |
| Default branch ruleset `protect-main` | active (all managed repos) |
| Tag ruleset `protect-tags` | active (all managed repos) |

All managed repositories are public, so every repo receives the full ruleset pair. (Rulesets and branch protection are unavailable to private repos on the free org plan, which is why no private repo may stay `RepoSettingsOnly` without losing merge gating.)

### Organization secrets (optional)

- Manage GitHub organization-level Actions secrets.
- Read secret material from 1Password via `external` provider + `op` CLI.
- Default visibility: `private`.

## Managed repositories

See `var.managed_repositories` in `variables.tf` (41 repositories today). The requested coverage set contains 34 repositories; seven additional managed repositories remain in the inventory: `graphql-java-datetime`, `jambalaya`, `pgquill`, `renovate-rust`, `tailrocks-gradle-conventions`, `tailrocks-logo`, and `tailrocks-sqldiff`.

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

Set each repository's `required_checks` in `managed_repositories` in `variables.tf` to the exact GitHub check-run names. Velnor Actions repositories use `Required`; the Control workflow repositories use `Control / Required`; `github-terraform` also requires `DCO`. All configured checks must pass on the pull request head, but the head does not need to include the latest default-branch commit. Resolved review threads, squash-only merging, and the other branch safeguards remain required for all managed repositories. GitHub's update-branch suggestion is disabled across the inventory.

`renovate-rust`, `tailrocks-logo`, `tailrocks-sqldiff`, and `vision` currently have no observed CI workflow check context, so their `required_checks` remain empty until a real CI check is available. The DCO app status on renovate-rust pull requests is not a CI workflow result.

## Emergency break-glass

Rulesets have zero standing bypasses, so when required checks are unhealthy (CI/Velnor outage) there is no legitimate merge path. Break-glass, org/repo admin only:

1. In **Settings → Rules → protect-main**, temporarily set enforcement to `disabled` (note the time and reason).
2. Merge the urgent fix via PR (squash-only merge methods are still enforced by repo settings; linear history and thread resolution are suspended with the ruleset).
3. Immediately re-enable enforcement to `active`.
4. Run the live audit (`LIVE_AUDIT=1 bash tests/verify-policy.sh`) to confirm all rulesets are active and match config.
5. Open a follow-up PR + postmortem note describing what was bypassed and why.

Never leave a ruleset disabled: the live audit fails loudly until it is restored.

## Notes

- Provider 6.x org secrets use `value` for secret text.
- `lifecycle.prevent_destroy` on managed repos stops IaC deletion only — UI deletion still possible for owners.
- Never commit `*.tfstate`, `*.tfvars`, or tokens.
