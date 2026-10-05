# TailRocks GitHub Org OpenTofu (Public)

Manage TailRocks GitHub organization settings with OpenTofu: organization and Actions policy, five retained repository-policy exceptions, and (optionally) organization Actions secrets via 1Password.

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

### Repository policy ownership

Repository merge settings and branch/tag rulesets for the TailRocks fleet are
being consolidated in the [ChainArgos control-plane root](https://github.com/ChainArgos/github-terraform).
Do not add other TailRocks repositories to this root. `graphql-java-datetime`,
`jambalaya`, `renovate-rust`, `tailrocks-logo`, and `tailrocks-sqldiff` are
excluded from central management and remain under this root with their existing
settings and rulesets unchanged. `graphql-java-datetime` retains its `Policy`
check. `jambalaya` has no required-status rule in its live ruleset, so its local
configuration preserves that state; the other three also remain without
required CI check contexts.

This root continues to own TailRocks organization settings, Actions permissions,
the `velnor-trusted` runner group, and organization Actions secrets. The policy
handoff uses state-only retirement and resource-address moves; it does not
delete GitHub repositories, settings, or rulesets. Apply the retirement only
after the central root has imported and verified the corresponding resources.

### Organization secrets (optional)

- Manage GitHub organization-level Actions secrets.
- Read secret material from 1Password via `external` provider + `op` CLI.
- Default visibility: `private`.

## Managed repositories

`var.managed_repositories` contains only the five retained exceptions listed
above. The central control-plane root owns the other 36 TailRocks repository
policies. Existing state is forgotten with `destroy = false` only after the
central root has imported and verified those resources; this root never deletes
their GitHub objects.

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

Organization resources and the five retained exceptions are imported via `imports.tf` on first apply.

## Required status checks

Required check contexts and merge safeguards for the 36 centrally managed
repositories are maintained by the central control-plane root. The five local
exceptions retain their observed contexts: `Policy` for
`graphql-java-datetime`, and none for the other four. In particular,
`jambalaya`'s existing live ruleset has no required-status rule. For
`renovate-rust`, the DCO app status is not a CI workflow result; this root does
not invent new required status checks.

## Emergency break-glass

Rulesets have zero standing bypasses, so when required checks are unhealthy (CI/Velnor outage) there is no legitimate merge path. Break-glass, org/repo admin only:

1. In **Settings → Rules → protect-main**, temporarily set enforcement to `disabled` (note the time and reason).
2. Merge the urgent fix via PR (squash-only merge methods are still enforced by repo settings; linear history and thread resolution are suspended with the ruleset).
3. Immediately re-enable enforcement to `active`.
4. Run the live audit (`LIVE_AUDIT=1 bash tests/verify-policy.sh`) for this root's five exceptions, then run the live audit from the central control-plane root for its 36 repositories.
5. Open a follow-up PR + postmortem note describing what was bypassed and why.

Never leave a ruleset disabled: the live audit fails loudly until it is restored.

## Notes

- Provider 6.x org secrets use `value` for secret text.
- `lifecycle.prevent_destroy` on managed repos stops IaC deletion only — UI deletion still possible for owners.
- Never commit `*.tfstate`, `*.tfvars`, or tokens.
