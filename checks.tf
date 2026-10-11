# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

# Deterministic invariant assertions to prevent policy weakening and inventory omissions

check "mandatory_target_repositories_present" {
  assert {
    condition = toset(keys(var.repository_policies)) == toset([
      "cloudflare-tofu", "github-terraform", "graphql-java-datetime", "holla",
      "holla-apt", "homebrew-holla", "homebrew-parallax", "homebrew-ruxel",
      "homebrew-tablerock", "homebrew-velnor", "jambalaya", "parallax",
      "parallax-telemetry-playground", "pg-bigdecimal", "pgquill",
      "renovate-rust", "ruxel", "schemalane", "tablerock",
      "tailrocks-code-quality-skills", "tailrocks-gradle-conventions",
      "tailrocks-logo", "tailrocks-macos-skills",
      "tailrocks-open-source-skills", "tailrocks-pull-request-skills",
      "tailrocks-roadmap-skills", "tailrocks-rust-skills",
      "tailrocks-skill-authoring-skills", "tailrocks-skills",
      "tailrocks-sqldiff", "tailrocks-typescript-skills",
      "terminal-components-claude", "termpane", "termrock",
      "tracing-request-level", "tui-snap", "velnor",
      "velnor-actions-fixture", "velnor-apt", "velnor-new", "vision",
    ])
    error_message = "repository_policies must contain exactly the 41 managed tailrocks repositories."
  }
}

check "all_managed_repositories_have_checks_or_reason" {
  assert {
    condition = alltrue([
      for name, policy in var.repository_policies :
      (
        length(policy.required_checks) > 0
        && alltrue([for c in policy.required_checks : trimspace(c) != ""])
        && policy.no_ci_reason == null
        ) || (
        length(policy.required_checks) == 0
        && policy.no_ci_reason != null
        && trimspace(policy.no_ci_reason) != ""
      )
    ])
    error_message = "Each entry must satisfy: non-empty blank-free required_checks with null no_ci_reason, XOR empty checks with non-empty no_ci_reason."
  }
}

check "no_ci_exception_allowlist_is_explicit" {
  assert {
    condition = toset([
      for name, policy in var.repository_policies : name
      if policy.no_ci_reason != null
    ]) == toset(["jambalaya", "renovate-rust", "tailrocks-logo", "tailrocks-sqldiff", "vision"])
    error_message = "Only jambalaya, renovate-rust, tailrocks-logo, tailrocks-sqldiff, and vision may carry a no_ci_reason exception."
  }
}

check "self_protection_enforced" {
  assert {
    condition     = contains(keys(var.repository_policies), "github-terraform")
    error_message = "tailrocks/github-terraform must remain in the managed repository inventory; every inventory entry receives both rulesets."
  }
}

check "self_merge_gates_enforced" {
  assert {
    condition = (
      var.repository_policies["github-terraform"].required_checks == tolist(["DCO", "Required"]) &&
      module.repository_policy.ruleset_pull_request["github-terraform"].required_review_thread_resolution == true
    )
    error_message = "tailrocks/github-terraform must require the observed DCO and Required checks and resolved review threads."
  }
}

check "terminal_components_merge_gates_enforced" {
  assert {
    condition = (
      var.repository_policies["terminal-components-claude"].required_checks == tolist(["Required"]) &&
      module.repository_policy.ruleset_pull_request["terminal-components-claude"].required_review_thread_resolution == true
    )
    error_message = "tailrocks/terminal-components-claude must require its green Required check and resolved review threads."
  }
}

check "update_branch_suggestions_disabled" {
  assert {
    condition = alltrue([
      for name, settings in module.repository_policy.repository_settings :
      settings.allow_update_branch == false
    ])
    error_message = "All managed repositories must disable GitHub's update-branch suggestion."
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

check "thread_resolution_and_active_enforcement" {
  assert {
    condition = alltrue([
      for name, gate in module.repository_policy.ruleset_enforcement :
      gate.enforcement == "active" &&
      gate.tags_enforcement == "active" &&
      gate.required_review_thread_resolution == true
    ])
    error_message = "All protect-main/protect-tags rulesets must enforce active with required review-thread resolution."
  }
}

check "zero_bypass_actors" {
  assert {
    condition = alltrue([
      for name, gate in module.repository_policy.ruleset_enforcement :
      length(gate.bypass_actors) == 0
    ])
    error_message = "No repository may declare bypass actors on its protect-main ruleset."
  }
}
