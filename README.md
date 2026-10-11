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
   allowlist check in `checks.tf`, and add the name to the mandatory list in
   `mandatory_target_repositories_present` in `checks.tf` (updating its count
   and message).
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
- Run tofu with `GITHUB_TOKEN` exported in the shell (same as the other
  github-terraform repos). The token needs org admin on `tailrocks` (org
  settings, Actions policies, runner group) plus Administration: write on
  every managed repository.
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

OpenTofu is pinned via `mise.toml` (opentofu 1.13.1); existing repos are
imported via `imports.tf` on first apply. Related reference:
`jackin-project/github-terraform`.
