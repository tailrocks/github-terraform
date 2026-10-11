# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

output "managed_repositories" {
  description = "Set of managed repository names (inventory keys)"
  value       = local.managed_repositories
}

output "repository_settings" {
  description = "Map of repository merge and lifecycle settings"
  value = {
    for k, v in github_repository.managed_settings : k => {
      allow_squash_merge          = v.allow_squash_merge
      allow_merge_commit          = v.allow_merge_commit
      allow_rebase_merge          = v.allow_rebase_merge
      squash_merge_commit_title   = v.squash_merge_commit_title
      squash_merge_commit_message = v.squash_merge_commit_message
      allow_update_branch         = v.allow_update_branch
      delete_branch_on_merge      = v.delete_branch_on_merge
      visibility                  = v.visibility
    }
  }
}

output "required_check_contexts" {
  description = "Map of repository name to its required status-check contexts"
  value = {
    for k, v in var.repository_policies : k => v.required_checks
  }
}

output "repository_ids" {
  description = "Map of repository name to repository ID"
  value = {
    for k, v in github_repository.managed_settings : k => v.repo_id
  }
}

output "ruleset_enforcement" {
  description = "Map of protect-main ruleset enforcement gates per repository"
  value = {
    for k, v in github_repository_ruleset.protect_main : k => {
      enforcement                       = v.enforcement
      tags_enforcement                  = github_repository_ruleset.protect_tags[k].enforcement
      required_review_thread_resolution = v.rules[0].pull_request[0].required_review_thread_resolution
      bypass_actors                     = v.bypass_actors
    }
  }
}

output "ruleset_pull_request" {
  description = "Map of protect-main ruleset pull-request merge gates per repository"
  value = {
    for k, v in github_repository_ruleset.protect_main : k => {
      enforcement                       = v.enforcement
      tags_enforcement                  = github_repository_ruleset.protect_tags[k].enforcement
      required_review_thread_resolution = v.rules[0].pull_request[0].required_review_thread_resolution
      allowed_merge_methods             = v.rules[0].pull_request[0].allowed_merge_methods
    }
  }
}
