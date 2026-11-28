# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

variable "github_organization" {
  type        = string
  description = "GitHub organization name for TailRocks"
  default     = "tailrocks"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT or GitHub App token with org admin scopes. Prefer GITHUB_TOKEN env for the provider; this var is optional when GITHUB_TOKEN is set."
  sensitive   = true
  default     = null
}

variable "repository_policies" {
  description = "Authoritative inventory of managed repositories and their visibility and check policy."
  type = map(object({
    visibility      = string
    required_checks = list(string)
    no_ci_reason    = optional(string)
    # Archived repositories are read-only on GitHub: their settings are not managed
    # and only their rulesets are tracked.
    archived = optional(bool, false)
    # Require branches to be up to date with the default branch before merging.
    strict_required_status_checks = optional(bool, false)
    # Also block moving existing tags (the update rule) in protect-tags.
    protect_tags_update = optional(bool, false)
    # Extra tag rulesets, keyed by ruleset name, that restrict tag creation for the
    # include patterns to the listed user IDs and GitHub App (Integration) IDs.
    tag_creation_rulesets = optional(map(object({
      include         = list(string)
      bypass_user_ids = list(number)
      bypass_app_ids  = optional(list(number), [])
    })), {})
    # Let repository admins bypass protect-main, only through a pull request (admin merge).
    admin_pull_request_bypass = optional(bool, false)
    # Merge queue on the default branch. null (the default) leaves the queue off.
    merge_queue = optional(object({
      grouping_strategy                 = string
      max_entries_to_build              = number
      max_entries_to_merge              = number
      min_entries_to_merge              = number
      min_entries_to_merge_wait_minutes = number
      check_response_timeout_minutes    = number
      merge_method                      = string
    }))
    # Protect-main is always managed for public repositories. false skips protect-tags.
    protect_tags = optional(bool, true)
    # Require resolved review threads on protect-main. false drops that requirement.
    review_thread_resolution = optional(bool, true)
    # Required check context -> ID of the app that must post it on protect-main
    # (15368 = GitHub Actions, 974774 = the cncf/dco2 app that posts DCO). A check
    # that is not listed accepts any source.
    required_check_apps = optional(map(number), {})
    # Merge policy override. null (the default) keeps the organization policy:
    # squash-only, delete branch on merge, linear history. Set only with a reason.
    merge_settings = optional(object({
      allow_squash_merge          = bool
      allow_merge_commit          = bool
      allow_rebase_merge          = bool
      delete_branch_on_merge      = bool
      squash_merge_commit_title   = string
      squash_merge_commit_message = string
      merge_commit_title          = optional(string)
      merge_commit_message        = optional(string)
      allowed_merge_methods       = list(string)
      required_linear_history     = bool
    }))
  }))

  validation {
    condition = alltrue([
      for repo in values(var.repository_policies) :
      contains(["public", "private"], repo.visibility)
    ])
    error_message = "Each managed repository visibility must be either public or private."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repository_policies) :
      length(repo.required_checks) > 0
      ? (
        alltrue([for context in repo.required_checks : trimspace(context) != ""]) &&
        repo.no_ci_reason == null
      )
      : try(length(trimspace(repo.no_ci_reason)) > 0, false)
    ])
    error_message = "Each repository must declare non-empty required checks or a non-empty no_ci_reason for an explicit no-CI exception."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repository_policies) :
      length(setsubtract(keys(repo.required_check_apps), repo.required_checks)) == 0
    ])
    error_message = "Every required_check_apps key must be one of the repository's required_checks; a pin on a check that is not required is silently ignored."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repository_policies) :
      repo.archived || !contains(repo.required_checks, "DCO") || lookup(repo.required_check_apps, "DCO", null) == local.dco_app_id
    ])
    error_message = "Every non-archived repository that requires DCO must pin it to the cncf/dco2 app (${local.dco_app_id}), or any workflow job named DCO can satisfy the requirement."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repository_policies) :
      alltrue([for app_id in values(repo.required_check_apps) : coalesce(app_id, 0) > 0])
    ])
    error_message = "Every required_check_apps value must be a positive app ID: null and 0 both mean any source to the provider."
  }

  validation {
    # Checks pinned to GitHub Actions (app 15368) beyond DCO. An error, not a check block, so a
    # stale override that drops the pin fails the plan instead of loosening the live ruleset.
    condition = alltrue([
      for name, context in { termrock = "Required", ruxel = "Acceptance local", velnor-new = "Required" } :
      !contains(keys(var.repository_policies), name) || lookup(var.repository_policies[name].required_check_apps, context, null) == 15368
    ])
    error_message = "termrock Required, ruxel Acceptance local and velnor-new Required must stay pinned to GitHub Actions (app 15368)."
  }

  validation {
    # An error, not a check block, so that a stale override fails the plan instead of widening
    # who may merge into the default branch past the rules.
    condition = alltrue([
      for name, repo in var.repository_policies :
      !repo.admin_pull_request_bypass || name == "velnor-new"
    ])
    error_message = "Only velnor-new may set admin_pull_request_bypass (owner approved 2026-11-19): it lets repository admins merge a pull request past protect-main."
  }

  validation {
    # An error, not a check block: the release tags of velnor-new are created by the owner and
    # by the velnor-release GitHub App, nobody else (tailrocks/velnor-new#682). tools-v* is the
    # family tag the release environment trusts, so it must be covered. The patterns equal those
    # of velnor-new's own scripts/tag-ruleset-drift.mjs. Tag immutability (protect_tags and
    # protect_tags_update) is required here too: an override must not drop the update and
    # deletion rules that keep an existing release tag from being moved.
    condition = !contains(keys(var.repository_policies), "velnor-new") || try(
      var.repository_policies["velnor-new"].protect_tags &&
      var.repository_policies["velnor-new"].protect_tags_update &&
      toset(var.repository_policies["velnor-new"].tag_creation_rulesets["release-tags"].include) == toset([
        "refs/tags/rust-ci-v*", "refs/tags/velnor-ci-v*", "refs/tags/velnor-gen-v*", "refs/tags/tools-v*",
      ]) &&
      toset(var.repository_policies["velnor-new"].tag_creation_rulesets["release-tags"].bypass_user_ids) == toset([139017]) &&
      toset(var.repository_policies["velnor-new"].tag_creation_rulesets["release-tags"].bypass_app_ids) == toset([5762496]),
      false,
    )
    error_message = "tailrocks/velnor-new must keep the release-tags ruleset: rust-ci-v*, velnor-ci-v*, velnor-gen-v* and tools-v* tags, created only by the owner (user 139017) and the velnor-release App (5762496), with protect_tags and protect_tags_update true (tailrocks/velnor-new#682)."
  }

  # NOTE: variable defaults must be literals, so entries cannot reference
  # local.check_templates. Keep these lists in sync with locals.tf templates.
  default = {
    "cloudflare-tofu" = {
      visibility          = "public"
      required_checks     = ["DCO"]
      required_check_apps = { DCO = 974774 }
    }
    "github-terraform" = {
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "graphql-java-datetime" = {
      visibility      = "public"
      required_checks = ["Policy"]
    }
    "holla" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "holla-apt" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "homebrew-holla" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "homebrew-parallax" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "homebrew-ruxel" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "homebrew-tablerock" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "homebrew-velnor-legacy" = {
      archived = true
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "jambalaya" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "Live protect-main ruleset carries no required status-check rule; no CI workflow emits a status context."
    }
    "parallax" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "parallax-telemetry-playground" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "pg-bigdecimal" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "pgquill" = {
      visibility      = "public"
      required_checks = ["Control / Required"]
    }
    "renovate-rust" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow emits a status context; DCO app results are not a CI check."
    }
    "repo-scan" = {
      # local.check_templates.required_only
      visibility      = "public"
      required_checks = ["Required"]
    }
    "rust-repository-policy" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow emits a status context on the default branch; only tag-push release checks exist."
    }
    "ruxel" = {
      # Acceptance local is posted by GitHub Actions (ruxel acceptance job).
      visibility          = "public"
      required_checks     = ["DCO", "Required", "Acceptance local"]
      required_check_apps = { DCO = 974774, "Acceptance local" = 15368 }
    }
    "schemalane" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "tablerock" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "tailrocks-asd-ste100-skills" = {
      # Private on the free plan: GitHub refuses rulesets here (403 "Upgrade to GitHub Pro"),
      # so the module declares none for it. Check list kept for the day it goes public.
      # local.check_templates.required_only
      visibility      = "private"
      required_checks = ["Required"]
    }
    "tailrocks-code-quality-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-contribution-skills" = {
      # local.check_templates.required_only
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-gradle-conventions" = {
      visibility      = "public"
      required_checks = ["Control / Required"]
    }
    "tailrocks-logo" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
    }
    "tailrocks-macos-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-pull-request-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-repository-skills" = {
      # local.check_templates.required_only
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-roadmap-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-rust-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-skill-authoring-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-skills" = {
      visibility          = "public"
      required_checks     = ["DCO"]
      required_check_apps = { DCO = 974774 }
    }
    "tailrocks-sqldiff" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
    }
    "tailrocks-typescript-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "taskrock" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "taskrock-plugins" = {
      # local.check_templates.dco_required (velnor-gen CI since taskrock-plugins#43)
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "terminal-components-claude" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "termpane" = {
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
      protect_tags_update = true
    }
    "termrock" = {
      # Former terminal-components-baseline. Merge settings are its live values (read 2026-11-20).
      # Protect-main only, by security review: requires the "Required" check from GitHub Actions,
      # blocks force-push and deletion, and needs no approvals or thread resolution, because bots
      # and agents merge after CI. TODO: protect-tags is skipped (protect_tags = false); decide later.
      visibility               = "public"
      required_checks          = ["Required"]
      protect_tags             = false
      review_thread_resolution = false
      required_check_apps      = { Required = 15368 } # GitHub Actions
      merge_settings = {
        allow_squash_merge          = true
        allow_merge_commit          = true
        allow_rebase_merge          = true
        delete_branch_on_merge      = false
        squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
        squash_merge_commit_message = "COMMIT_MESSAGES"
        merge_commit_title          = "MERGE_MESSAGE"
        merge_commit_message        = "PR_TITLE"
        allowed_merge_methods       = ["merge", "squash", "rebase"]
        required_linear_history     = false
      }
    }
    "termrock-legacy" = {
      # Former tailrocks/termrock, archived: only its rulesets are managed.
      # local.check_templates.dco_required
      archived        = true
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "tracing-request-level" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "tuiscotti" = {
      # Bespoke: matches live protect-main ruleset 23746094 required contexts (DCO + Required).
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
    }
    "velnor-actions-fixture-legacy" = {
      archived        = true
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-apt-legacy" = {
      archived = true
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "velnor-lab" = {
      # local.check_templates.dco_required
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      required_check_apps = { DCO = 974774 }
      protect_tags_update = true
    }
    "velnor-legacy" = {
      archived = true
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "velnor-new" = {
      # Live ruleset 24396608 requires only "Required" (checked 2026-11-28), and pins it to
      # GitHub Actions: the check-runs of the last merged pull requests and of their merge_group
      # commits all name app 15368.
      visibility          = "public"
      required_checks     = ["Required"]
      required_check_apps = { Required = 15368 } # GitHub Actions
      # Owner approved 2026-11-19: admin merges for rare critical-path cases.
      admin_pull_request_bypass = true
      protect_tags_update       = true
      # Batched queue, as live (ruleset 24396608, read 2026-11-28): HEADGREEN, so only the newest
      # entry of a group must pass; up to 5 entries build and 5 merge per run.
      merge_queue = {
        grouping_strategy                 = "HEADGREEN"
        max_entries_to_build              = 5
        max_entries_to_merge              = 5
        min_entries_to_merge              = 1
        min_entries_to_merge_wait_minutes = 5
        check_response_timeout_minutes    = 90
        merge_method                      = "SQUASH"
      }
      tag_creation_rulesets = {
        # Only the owner and the velnor-release GitHub App may create release tags
        # (tailrocks/velnor-new#682). The owner pushes the tools-v* tags that start the release
        # workflow; the App token creates a family tag the job finds missing. tools-v* is the
        # family tag of .velnor/release.toml. runner-v* is not released (release-plz.toml
        # release = false) and actions-v* went with the old engine (#1459), so neither is
        # reserved, as in velnor-new's tag-ruleset-drift.mjs. Prefix list first proposed in #65.
        "release-tags" = {
          include         = ["refs/tags/rust-ci-v*", "refs/tags/velnor-ci-v*", "refs/tags/velnor-gen-v*", "refs/tags/tools-v*"]
          bypass_user_ids = [139017]  # donbeave
          bypass_app_ids  = [5762496] # velnor-release
        }
        "sdk-preview-owner-creation" = {
          include         = ["refs/tags/sdk-preview-*"]
          bypass_user_ids = [139017] # donbeave
        }
      }
    }
    "vision" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
    }
  }
}

variable "velnor_runner_groups" {
  description = "Velnor Actions runner groups, keyed by group name. Each group is restricted to its repositories; a non-empty selected_workflows list also restricts it to those workflows (owner/repo/path@ref)."
  type = map(object({
    repositories       = set(string)
    selected_workflows = optional(list(string), [])
  }))
  # Live groups 4 and 5, read 2026-11-28 from orgs/tailrocks/actions/runner-groups.
  default = {
    "velnor-ci" = {
      repositories = ["ruxel", "termpane", "tuiscotti", "velnor-lab", "velnor-new"]
    }
    "velnor-ci-trusted" = {
      repositories = ["velnor-new"]
      selected_workflows = [
        "tailrocks/velnor-new/.github/workflows/qualification.yml@refs/heads/main",
      ]
    }
  }

  validation {
    condition = length(setsubtract(
      toset(flatten([for group in var.velnor_runner_groups : tolist(group.repositories)])),
      keys(var.repository_policies),
    )) == 0
    error_message = "velnor_runner_groups repositories must be a subset of repository_policies."
  }

  validation {
    # An empty list means any workflow, so any workflow of velnor-new would run on the trusted group.
    condition     = length(lookup(var.velnor_runner_groups, "velnor-ci-trusted", { repositories = [], selected_workflows = ["-"] }).selected_workflows) > 0
    error_message = "velnor-ci-trusted must keep a non-empty selected_workflows allowlist: an empty list lets every workflow of its repositories use the group."
  }

  validation {
    # A workflow reference on any other ref (a staging branch, a tag) is writable by whoever can
    # push there, and that code would then run on the trusted group. Only the protected default
    # branch qualifies.
    condition = alltrue([
      for workflow in lookup(var.velnor_runner_groups, "velnor-ci-trusted", { repositories = [], selected_workflows = [] }).selected_workflows :
      endswith(workflow, "@refs/heads/main")
    ])
    error_message = "Every velnor-ci-trusted selected_workflows entry must be pinned to refs/heads/main (owner/repo/path@refs/heads/main): any other ref is writable outside the protected branch."
  }
}
