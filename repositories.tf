# Temporary local policy exceptions. The other 38 repositories are owned by
# the central control-plane root.

module "retained_policy_exceptions" {
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

# Preserve the three excluded repositories at their new module addresses
# without changing their GitHub objects.
moved {
  from = module.repository_policy.github_repository.managed_settings["renovate-rust"]
  to   = module.retained_policy_exceptions.github_repository.managed_settings["renovate-rust"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["renovate-rust"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_main["renovate-rust"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["renovate-rust"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["renovate-rust"]
}

moved {
  from = module.repository_policy.github_repository.managed_settings["tailrocks-logo"]
  to   = module.retained_policy_exceptions.github_repository.managed_settings["tailrocks-logo"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["tailrocks-logo"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_main["tailrocks-logo"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["tailrocks-logo"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["tailrocks-logo"]
}

moved {
  from = module.repository_policy.github_repository.managed_settings["tailrocks-sqldiff"]
  to   = module.retained_policy_exceptions.github_repository.managed_settings["tailrocks-sqldiff"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["tailrocks-sqldiff"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_main["tailrocks-sqldiff"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["tailrocks-sqldiff"]
  to   = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["tailrocks-sqldiff"]
}

# Relinquish the prior 41-repository module after central adoption. This only
# forgets remaining objects from this root's state; it never deletes GitHub
# repositories, settings, or rulesets.
removed {
  from = module.repository_policy

  lifecycle {
    destroy = false
  }
}
