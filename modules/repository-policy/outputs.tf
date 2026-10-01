output "managed_settings_repositories" {
  description = "Set of repository names with managed repository-level merge settings"
  value       = local.managed_settings_repositories
}

output "full_ruleset_repositories" {
  description = "Set of repository names with active branch and tag rulesets"
  value       = local.full_ruleset_repositories
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

output "repository_ids" {
  description = "Map of repository name to repository ID"
  value = {
    for k, v in github_repository.managed_settings : k => v.repo_id
  }
}
