# github-terraform

Manages GitHub repository settings and branch/tag protection for the
`tailrocks` organization: 49 repositories, each with repository merge
settings plus `protect-main` and `protect-tags` rulesets, and optional
per-repository tag-creation rulesets. Two exceptions: archived repositories
(`archived = true`) get no managed settings, because GitHub refuses changes to
them, and private repositories get no rulesets, because the free plan returns
403 for them.

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

## Authentication

Run tofu with `GITHUB_TOKEN` exported in the shell, or via the mise tasks
`mise run tofu:plan` / `mise run tofu:apply`, which inject the organization
token from 1Password. The token needs Administration: write on every managed
repository. It also needs org admin on `tailrocks` for the organization
settings, Actions policies, and runner group in `organization.tf`.

## Adding a repository

1. Add one entry to `repository_policies` in `variables.tf`, copying a check
   list from `locals.tf` (`dco_policy_ci` = `["DCO", "Policy", "ci-required"]`,
   `dco_required` = `["DCO", "Required"]`,
   `control` = `["Control / Required"]`, `required_only` = `["Required"]`,
   `dco_only` = `["DCO"]`, `policy` = `["Policy"]`); bespoke checks inline
   with a comment citing the producing workflow. Repos with no CI use
   `required_checks = []` plus a non-empty `no_ci_reason` and extend the
   allowlist check in `checks.tf`. Always add the name to the mandatory list
   in `mandatory_target_repositories_present` in `checks.tf` (updating its
   count and message).
2. Add one import triple (settings + `protect_main` + `protect_tags`) to
   `imports.tf` using the live numeric ruleset IDs. A private repository gets
   only the settings import; an archived one gets only the two ruleset imports.
3. Set the pull-request creation policy, which the provider cannot manage yet
   (integrations/terraform-provider-github#3479):
   `gh api -X PATCH repos/tailrocks/<repo> -f pull_request_creation_policy=collaborators_only`.
   Check it with `gh api repos/tailrocks/<repo> --jq .pull_request_creation_policy`.

## Per-repository options

Each `repository_policies` entry may also set:

- `protect_tags` (default `true`): set `false` to skip the protect-tags ruleset.
  Only `termrock` does (TODO in `variables.tf`).
- `review_thread_resolution` (default `true`): set `false` to drop the requirement
  to resolve review threads on protect-main. Only `termrock` does.
- `required_check_apps` (default `{}`): map from a required check context to the ID of
  the app that must post it on protect-main. `15368` is GitHub Actions and `974774`
  is the cncf/dco2 app. A check that is not listed accepts any source. Every
  repository that requires `DCO` pins it to `974774` (a `variables.tf` validation, in the root and the module, enforces this);
  only `termrock` pins another check (`Required` to `15368`). Read an app ID from
  live data, not from memory:
  `gh api repos/tailrocks/<repo>/commits/<sha>/check-runs --jq '.check_runs[] | {name, app: .app.slug, id: .app.id}'`.
- `merge_settings` (default `null`): the merge policy. `null` is the organization
  policy (squash-only, delete branch on merge, linear history, PR_TITLE/PR_BODY).
  Only `termrock` overrides it, to keep the merge-commit policy of the repository
  it was renamed from. `checks.tf` pins that exception list.
- `archived` (default `false`): set it for a repository that is archived on
  GitHub. The module then skips its settings and reads its ID through a data
  source; its rulesets stay managed.
- `strict_required_status_checks` (default `false`): require the branch to be
  up to date with the default branch before merging.
- `protect_tags_update` (default `false`): add the `update` rule to
  `protect-tags`, so that existing tags cannot move.
- `tag_creation_rulesets` (default `{}`): extra tag rulesets, keyed by ruleset
  name, with the `creation` rule for the `include` patterns and an `always`
  bypass for each user in `bypass_user_ids`. Import each existing ruleset as
  `tag_creation["<repository>/<ruleset name>"]` in `imports.tf`.

## Organization overlays

- `organization.tf` manages the org profile (`github_organization_settings`),
  Actions availability/allow policy (`github_actions_organization_permissions`),
  default `GITHUB_TOKEN` workflow permissions
  (`github_actions_organization_workflow_permissions`), and the
  `velnor-trusted` runner group restricted to
  `var.velnor_runner_group_repositories` (must be a subset of
  `repository_policies`).
- GitHub does not expose organization package-creation visibility through the
  REST API or the Terraform GitHub provider; manage those settings in
  **Organization settings → Packages**. Making a package public is
  irreversible.

## Verification

```sh
tofu fmt -check -recursive
tofu init -backend=false -input=false -lockfile=readonly
tofu validate -no-color
```

OpenTofu is pinned via `mise.toml` (opentofu 1.13.1); existing repos are
imported via `imports.tf` on first apply.
