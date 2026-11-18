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
    # include patterns to the listed user IDs.
    tag_creation_rulesets = optional(map(object({
      include         = list(string)
      bypass_user_ids = list(number)
    })), {})
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

  # NOTE: variable defaults must be literals, so entries cannot reference
  # local.check_templates. Keep these lists in sync with locals.tf templates.
  default = {
    "cloudflare-tofu" = {
      visibility      = "public"
      required_checks = ["DCO"]
    }
    "github-terraform" = {
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "graphql-java-datetime" = {
      visibility      = "public"
      required_checks = ["Policy"]
    }
    "holla" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "holla-apt" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "homebrew-holla" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "homebrew-parallax" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "homebrew-ruxel" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "homebrew-tablerock" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
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
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "parallax-telemetry-playground" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "pg-bigdecimal" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
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
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "schemalane" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "tablerock" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
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
      visibility      = "public"
      required_checks = ["DCO"]
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
    "terminal-components-claude" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "termpane" = {
      visibility          = "public"
      required_checks     = ["DCO", "Required"]
      protect_tags_update = true
    }
    "termrock" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "tracing-request-level" = {
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "tuiscotti" = {
      # Bespoke: matches live protect-main ruleset 23746094 required contexts (DCO + Required).
      visibility      = "public"
      required_checks = ["DCO", "Required"]
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
      protect_tags_update = true
    }
    "velnor-legacy" = {
      archived = true
      # local.check_templates.dco_required
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "velnor-new" = {
      # Bespoke: during the transition after tailrocks/velnor-new#604 the new Rust
      # workflow keeps the check name "rust-required" and the old ci.yml keeps "Required"
      # and "Required verdict"; the rename to a single name happens later, when
      # tailrocks/velnor-new#608 removes the old engine's Rust CI path. "Required
      # verdict" is the other live protect-main ruleset 24396608 context.
      visibility          = "public"
      required_checks     = ["DCO", "Required", "Required verdict", "rust-required"]
      protect_tags_update = true
      # Batched queue (owner decision 2026-11-18): 13 runners fit about one full CI run,
      # so only the newest entry of a group must pass and up to 10 PRs merge per run.
      merge_queue = {
        grouping_strategy                 = "HEADGREEN"
        max_entries_to_build              = 2
        max_entries_to_merge              = 10
        min_entries_to_merge              = 1
        min_entries_to_merge_wait_minutes = 5
        check_response_timeout_minutes    = 90
        merge_method                      = "SQUASH"
      }
      tag_creation_rulesets = {
        # Only the owner may create release tags (tailrocks/velnor-new#682).
        # The velnor-release GitHub App replaces this bypass later.
        "release-tags" = {
          include         = ["refs/tags/rust-ci-v*", "refs/tags/velnor-ci-v*", "refs/tags/velnor-gen-v*"]
          bypass_user_ids = [139017] # donbeave
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

variable "velnor_runner_group_repositories" {
  description = "Repositories allowed to schedule jobs on the velnor-trusted Actions runner group."
  type        = set(string)
  default = [
    "cloudflare-tofu",
    "holla",
    "parallax",
    "parallax-telemetry-playground",
    "pg-bigdecimal",
    "ruxel",
    "schemalane",
    "tablerock",
    "termrock",
    "tracing-request-level",
    "velnor-actions-fixture-legacy",
    "velnor-apt-legacy",
    "velnor-legacy",
  ]

  validation {
    condition     = length(setsubtract(var.velnor_runner_group_repositories, keys(var.repository_policies))) == 0
    error_message = "velnor_runner_group_repositories must be a subset of repository_policies."
  }
}
