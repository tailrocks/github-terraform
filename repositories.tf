# Managed repository settings + rulesets.
# Authoritative canonical module: modules/repository-policy
# Enforces squash-only merges, delete head branch, allow update branch,
# protect default branch + all tags with zero standing bypasses.

module "repository_policy" {
  source = "./modules/repository-policy"

  repository_policies = var.managed_repositories
}

moved {
  from = github_repository.managed_settings
  to   = module.repository_policy.github_repository.managed_settings
}

moved {
  from = github_repository_ruleset.protect_main
  to   = module.repository_policy.github_repository_ruleset.protect_main
}

moved {
  from = github_repository_ruleset.protect_tags
  to   = module.repository_policy.github_repository_ruleset.protect_tags
}
