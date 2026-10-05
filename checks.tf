# TailRocks retains repository policy only for five documented exclusions.
# The central control-plane root owns settings and rulesets for all others.

check "legacy_policy_scope_is_exactly_the_documented_exceptions" {
  assert {
    condition = (
      toset(keys(var.managed_repositories)) == toset(["graphql-java-datetime", "jambalaya", "renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"]) &&
      toset(module.retained_policy_exceptions.managed_settings_repositories) == toset(["graphql-java-datetime", "jambalaya", "renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"]) &&
      toset(module.retained_policy_exceptions.full_ruleset_repositories) == toset(["graphql-java-datetime", "jambalaya", "renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"])
    )
    error_message = "Only graphql-java-datetime, jambalaya, renovate-rust, tailrocks-logo, and tailrocks-sqldiff may remain managed by the TailRocks repository-policy root."
  }
}

check "retained_policy_exceptions_are_preserved" {
  assert {
    condition = alltrue([
      for name, expected_checks in {
        "graphql-java-datetime" = ["Policy"]
        "jambalaya"             = []
        "renovate-rust"         = []
        "tailrocks-logo"        = []
        "tailrocks-sqldiff"     = []
      } :
      var.managed_repositories[name].disposition == "FullRuleset" &&
      var.managed_repositories[name].visibility == "public" &&
      var.managed_repositories[name].required_checks == expected_checks &&
      module.retained_policy_exceptions.ruleset_pull_request[name].required_review_thread_resolution == true
    ])
    error_message = "The five exclusions must retain their current public/full-ruleset policy and exact required-check contexts."
  }
}

check "update_branch_suggestions_disabled" {
  assert {
    condition = alltrue([
      for settings in module.retained_policy_exceptions.repository_settings :
      settings.allow_update_branch == false
    ])
    error_message = "The retained exception policies must keep update-branch suggestions disabled."
  }
}

check "delete_branch_on_merge_mandate" {
  assert {
    condition = alltrue([
      for settings in module.retained_policy_exceptions.repository_settings :
      settings.delete_branch_on_merge == true
    ])
    error_message = "The retained exception policies must keep delete_branch_on_merge enabled."
  }
}

check "ruleset_enforcement_mandate" {
  assert {
    condition = alltrue([
      for rules in module.retained_policy_exceptions.ruleset_pull_request :
      rules.enforcement == "active" && rules.tags_enforcement == "active"
    ])
    error_message = "The retained exception rulesets must remain active."
  }
}

check "conversation_resolution_mandate" {
  assert {
    condition = alltrue([
      for rules in module.retained_policy_exceptions.ruleset_pull_request :
      rules.required_review_thread_resolution == true
    ])
    error_message = "The retained exception main rulesets must continue requiring resolved review threads."
  }
}

check "squash_only_merge_mandate" {
  assert {
    condition = alltrue([
      for settings in module.retained_policy_exceptions.repository_settings :
      settings.allow_squash_merge == true &&
      settings.allow_merge_commit == false &&
      settings.allow_rebase_merge == false &&
      settings.squash_merge_commit_title == "PR_TITLE" &&
      settings.squash_merge_commit_message == "PR_BODY"
    ])
    error_message = "The retained exception policies must remain squash-only."
  }
}
