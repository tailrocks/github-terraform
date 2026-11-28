# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_version = ">= 1.9"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }
}

locals {
  # Every inventory key; archived repositories are read-only on GitHub, so only the
  # active ones get managed settings.
  inventory_repositories = toset(keys(var.repository_policies))
  managed_repositories = toset([
    for name, policy in var.repository_policies : name if !policy.archived
  ])
  archived_repositories = setsubtract(local.inventory_repositories, local.managed_repositories)

  # Organization merge policy, used unless a repository sets merge_settings.
  canonical_merge_settings = {
    allow_squash_merge          = true
    allow_merge_commit          = false
    allow_rebase_merge          = false
    delete_branch_on_merge      = true
    squash_merge_commit_title   = "PR_TITLE"
    squash_merge_commit_message = "PR_BODY"
    merge_commit_title          = null
    merge_commit_message        = null
    allowed_merge_methods       = ["squash"]
    required_linear_history     = true
  }

  merge_settings = {
    for name, policy in var.repository_policies :
    name => policy.merge_settings != null ? policy.merge_settings : local.canonical_merge_settings
  }

  # A private repository on the free plan cannot have rulesets: the rulesets API
  # answers 403 "Upgrade to GitHub Pro".
  ruleset_repositories = toset([
    for name, policy in var.repository_policies : name if policy.visibility == "public"
  ])

  # protect-tags is skipped for repositories that set protect_tags = false.
  tag_ruleset_repositories = toset([
    for name, policy in var.repository_policies : name if policy.visibility == "public" && policy.protect_tags
  ])

  # Repository names for rulesets, taken from the settings resource when it exists.
  repository_names = merge(
    { for name, repo in github_repository.managed_settings : name => repo.name },
    { for name, repo in data.github_repository.archived : name => repo.name },
  )

  # Keyed "<repository>/<ruleset name>".
  tag_creation_rulesets = merge([
    for repository, policy in var.repository_policies : {
      for name, ruleset in policy.tag_creation_rulesets : "${repository}/${name}" => {
        repository      = repository
        name            = name
        include         = ruleset.include
        bypass_user_ids = ruleset.bypass_user_ids
        bypass_app_ids  = ruleset.bypass_app_ids
      }
    }
  ]...)
}

# Archived repositories: read only, so that their IDs stay available without any write.
data "github_repository" "archived" {
  for_each = local.archived_repositories

  name = each.value

  # The inventory flag exempts these repositories from writes and from the DCO pin, so it
  # must match GitHub: a repository reopened on GitHub but still marked archived here
  # would keep an unpinned DCO gate.
  lifecycle {
    postcondition {
      condition     = self.archived
      error_message = "${each.value} is marked archived = true in repository_policies but is not archived on GitHub; remove the flag and pin its checks."
    }
  }
}

# Repository-level merge settings (Tier 1 enforcement across all repos)
resource "github_repository" "managed_settings" {
  for_each = local.managed_repositories

  name       = each.value
  visibility = var.repository_policies[each.value].visibility

  # Merge policy: organization default (squash-only) or the repository's merge_settings.
  allow_squash_merge          = local.merge_settings[each.value].allow_squash_merge
  allow_merge_commit          = local.merge_settings[each.value].allow_merge_commit
  allow_rebase_merge          = local.merge_settings[each.value].allow_rebase_merge
  squash_merge_commit_title   = local.merge_settings[each.value].squash_merge_commit_title
  squash_merge_commit_message = local.merge_settings[each.value].squash_merge_commit_message
  merge_commit_title          = local.merge_settings[each.value].merge_commit_title
  merge_commit_message        = local.merge_settings[each.value].merge_commit_message

  # Keep GitHub from offering the pull-request branch-update action.
  allow_update_branch    = false
  delete_branch_on_merge = local.merge_settings[each.value].delete_branch_on_merge

  # TODO: pull_request_creation_policy = "collaborators_only" is set on every repository through the REST API
  # until the provider supports it: https://github.com/integrations/terraform-provider-github/pull/3479
  # Then add it here and widen the provider constraint in versions.tf and this module.

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      description,
      homepage_url,
      has_issues,
      has_projects,
      has_wiki,
      has_discussions,
      archived,
      topics,
      vulnerability_alerts,
      allow_auto_merge,
      web_commit_signoff_required,
      pages,
      security_and_analysis,
    ]
  }
}

# Branch ruleset on main / default branch (Tier 2 ref protection)
resource "github_repository_ruleset" "protect_main" {
  for_each = local.ruleset_repositories

  name        = "protect-main"
  target      = "branch"
  enforcement = "active"
  repository  = local.repository_names[each.value]

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # MANDATORY INVARIANT: Zero standing bypasses on core protections,
  # except the explicit admin_pull_request_bypass opt-in (pull_request mode only: no direct pushes).
  # Direct pushes, non-squash integration, force pushes, and deletion are blocked for all actors.

  dynamic "bypass_actors" {
    for_each = var.repository_policies[each.value].admin_pull_request_bypass ? [1] : []
    content {
      actor_id    = 5 # RepositoryRole: repository admin
      actor_type  = "RepositoryRole"
      bypass_mode = "pull_request"
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = local.merge_settings[each.value].required_linear_history

    pull_request {
      allowed_merge_methods             = local.merge_settings[each.value].allowed_merge_methods
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = false
      require_code_owner_review         = false
      required_review_thread_resolution = var.repository_policies[each.value].review_thread_resolution
    }

    dynamic "merge_queue" {
      for_each = var.repository_policies[each.value].merge_queue == null ? [] : [var.repository_policies[each.value].merge_queue]
      content {
        grouping_strategy                 = merge_queue.value.grouping_strategy
        max_entries_to_build              = merge_queue.value.max_entries_to_build
        max_entries_to_merge              = merge_queue.value.max_entries_to_merge
        min_entries_to_merge              = merge_queue.value.min_entries_to_merge
        min_entries_to_merge_wait_minutes = merge_queue.value.min_entries_to_merge_wait_minutes
        check_response_timeout_minutes    = merge_queue.value.check_response_timeout_minutes
        merge_method                      = merge_queue.value.merge_method
      }
    }

    dynamic "required_status_checks" {
      for_each = length(var.repository_policies[each.value].required_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = var.repository_policies[each.value].strict_required_status_checks
        do_not_enforce_on_create             = false

        dynamic "required_check" {
          for_each = var.repository_policies[each.value].required_checks
          content {
            context        = required_check.value
            integration_id = lookup(var.repository_policies[each.value].required_check_apps, required_check.value, null)
          }
        }
      }
    }
  }
}

# Tag ruleset protecting all tags
resource "github_repository_ruleset" "protect_tags" {
  for_each = local.tag_ruleset_repositories

  name        = "protect-tags"
  target      = "tag"
  enforcement = "active"
  repository  = local.repository_names[each.value]

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
    update           = var.repository_policies[each.value].protect_tags_update
  }
}

# Tag rulesets that let only the listed users and GitHub Apps create matching tags
resource "github_repository_ruleset" "tag_creation" {
  for_each = local.tag_creation_rulesets

  name        = each.value.name
  target      = "tag"
  enforcement = "active"
  repository  = local.repository_names[each.value.repository]

  conditions {
    ref_name {
      include = each.value.include
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_user_ids
    content {
      actor_id    = bypass_actors.value
      actor_type  = "User"
      bypass_mode = "always"
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_app_ids
    content {
      actor_id    = bypass_actors.value
      actor_type  = "Integration"
      bypass_mode = "always"
    }
  }

  rules {
    creation = true
  }
}
