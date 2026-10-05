# Deterministic invariant assertions for TailRocks GitHub policy management

check "mandatory_target_repositories_present" {
  assert {
    condition = alltrue([
      for r in [
        "velnor", "holla-apt", "homebrew-holla", "homebrew-tablerock", "homebrew-ruxel",
        "tablerock", "parallax", "schemalane", "ruxel", "pg-bigdecimal",
        "velnor-actions-fixture", "github-terraform", "tracing-request-level", "velnor-apt",
        "cloudflare-tofu", "homebrew-velnor", "termpane", "termrock",
        "parallax-telemetry-playground", "homebrew-parallax", "holla",
        "tailrocks-typescript-skills", "tailrocks-skill-authoring-skills", "tailrocks-rust-skills",
        "tailrocks-roadmap-skills", "tailrocks-pull-request-skills", "tailrocks-open-source-skills",
        "tailrocks-macos-skills", "tailrocks-code-quality-skills", "tailrocks-skills",
        "vision", "tui-snap", "terminal-components-claude", "velnor-new",
        "graphql-java-datetime", "jambalaya", "pgquill", "renovate-rust",
        "tailrocks-gradle-conventions", "tailrocks-logo", "tailrocks-sqldiff"
      ] : contains(keys(var.managed_repositories), r)
    ])
    error_message = "All 41 mandatory target repositories must be managed under TailRocks."
  }
}

check "self_protection_enforced" {
  assert {
    condition     = contains(keys(var.managed_repositories), "github-terraform")
    error_message = "tailrocks/github-terraform must be self-protected by this configuration."
  }
}

check "self_merge_gates_enforced" {
  assert {
    condition = (
      var.managed_repositories["github-terraform"].required_checks == tolist(["DCO", "Required"]) &&
      module.repository_policy.ruleset_pull_request["github-terraform"].required_review_thread_resolution == true
    )
    error_message = "tailrocks/github-terraform must require the observed DCO and Required checks and resolved review threads."
  }
}

check "delete_branch_on_merge_mandate" {
  assert {
    condition = alltrue([
      for k, v in module.repository_policy.repository_settings : v.delete_branch_on_merge == true
    ])
    error_message = "All managed repositories must enforce delete_branch_on_merge = true."
  }
}

check "ruleset_enforcement_mandate" {
  assert {
    condition = alltrue([
      for k, v in module.repository_policy.ruleset_pull_request : (
        v.enforcement == "active" && v.tags_enforcement == "active"
      )
    ])
    error_message = "All protect-main and protect-tags rulesets must have enforcement = active."
  }
}

check "conversation_resolution_mandate" {
  assert {
    condition = alltrue([
      for k, v in module.repository_policy.ruleset_pull_request : v.required_review_thread_resolution == true
    ])
    error_message = "All protect-main rulesets must require conversation resolution before merging."
  }
}

check "squash_only_merge_mandate" {
  assert {
    condition = alltrue([
      for k, v in module.repository_policy.repository_settings : (
        v.allow_squash_merge == true &&
        v.allow_merge_commit == false &&
        v.allow_rebase_merge == false &&
        v.squash_merge_commit_title == "PR_TITLE" &&
        v.squash_merge_commit_message == "PR_BODY"
      )
    ])
    error_message = "All managed repositories must enforce canonical squash-only merge policy."
  }
}
