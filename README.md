# github-terraform

Manages GitHub repository settings and branch/tag protection for the
`tailrocks` organization: 41 repositories, each with repository merge
settings plus `protect-main` and `protect-tags` rulesets.

## Layout

- `variables.tf` — `repository_policies` inventory (single source of truth).
- `locals.tf` — `check_templates` copy-paste source for check lists.
- `repositories.tf` — `module.repository_policy` wiring.
- `organization.tf` — organization settings, Actions/workflow permissions,
  and the `velnor-trusted` runner group.
- `main.tf` — organization Actions secrets wiring (1Password-sourced).
- `data-sources.tf` — 1Password items and `secret_selected` repo lookups.
- `modules/repository-policy/` — shared policy module (identical across orgs).
- `checks.tf` — invariant guards (no scripts).
- `imports.tf` — bootstrap import triples (one per repo: settings + 2 rulesets).
- `providers.tf`, `versions.tf`, `outputs.tf` — provider, pins, outputs.

## Adding a repository

1. Add one entry to `repository_policies` in `variables.tf`, copying a check
   list from `locals.tf` (`dco_policy_ci` = `["DCO", "Policy", "ci-required"]`,
   `control` = `["Control / Required"]`, `required_only` = `["Required"]`,
   `dco_only` = `["DCO"]`, `policy` = `["Policy"]`); bespoke checks inline
   with a comment citing the producing workflow. Repos with no CI use
   `required_checks = []` plus a non-empty `no_ci_reason` and extend the
   allowlist check in `checks.tf`.
2. Add one import triple (settings + `protect_main` + `protect_tags`) to
   `imports.tf` using the live numeric ruleset IDs.

## Organization overlays

- `organization.tf` manages the org profile (`github_organization_settings`),
  Actions availability/allow policy (`github_actions_organization_permissions`),
  default `GITHUB_TOKEN` workflow permissions
  (`github_actions_organization_workflow_permissions`), and the
  `velnor-trusted` runner group restricted to
  `var.velnor_runner_group_repositories` (must be a subset of
  `repository_policies`).
- Secrets wiring (`main.tf` + `data-sources.tf`): org Actions secrets come
  from 1Password via the `external` provider + `op` CLI; run tofu through the
  mise tasks so the GitHub token is injected from 1Password (never exported
  by hand): `mise run tofu:plan -- <plan args>`,
  `mise run tofu:apply -- <apply args>`. A secret with
  `visibility = "selected"` lists its repos, resolved through
  `data.github_repository.secret_selected`.
- GitHub does not expose organization package-creation visibility through the
  REST API or the Terraform GitHub provider; manage those settings in
  **Organization settings → Packages**. Making a package public is
  irreversible.

## Verification

```sh
cd /Users/donbeave/Projects/one/tailrocks-github-terraform
tofu fmt -check -recursive
tofu init -backend=false -input=false -lockfile=readonly
tofu validate -no-color
```

OpenTofu is pinned via `mise.toml` (opentofu 1.12.5); existing repos are
imported via `imports.tf` on first apply. Related reference:
`jackin-project/github-terraform`.
