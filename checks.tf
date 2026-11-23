# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

# Deterministic invariant assertions to prevent policy weakening and inventory omissions

check "mandatory_target_repositories_present" {
  assert {
    condition = toset(keys(var.repository_policies)) == toset([
      "cloudflare-tofu", "github-terraform", "graphql-java-datetime", "holla",
      "holla-apt", "homebrew-holla", "homebrew-parallax", "homebrew-ruxel",
      "homebrew-tablerock", "homebrew-velnor-legacy", "jambalaya", "parallax",
      "parallax-telemetry-playground", "pg-bigdecimal", "pgquill",
      "renovate-rust", "repo-scan", "rust-repository-policy", "ruxel",
      "schemalane", "tablerock", "tailrocks-asd-ste100-skills",
      "tailrocks-code-quality-skills", "tailrocks-contribution-skills",
      "tailrocks-gradle-conventions", "tailrocks-logo",
      "tailrocks-macos-skills",
      "tailrocks-pull-request-skills", "tailrocks-repository-skills",
      "tailrocks-roadmap-skills", "tailrocks-rust-skills",
      "tailrocks-skill-authoring-skills", "tailrocks-skills",
      "tailrocks-sqldiff", "tailrocks-typescript-skills", "taskrock",
      "terminal-components-claude", "termpane", "termrock", "termrock-legacy",
      "tracing-request-level", "tuiscotti", "velnor-actions-fixture-legacy",
      "velnor-apt-legacy", "velnor-lab", "velnor-legacy", "velnor-new", "vision",
    ])
    error_message = "repository_policies must contain exactly the 48 managed tailrocks repositories."
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
    ]) == toset(["jambalaya", "renovate-rust", "rust-repository-policy", "tailrocks-logo", "tailrocks-sqldiff", "vision"])
    error_message = "Only jambalaya, renovate-rust, rust-repository-policy, tailrocks-logo, tailrocks-sqldiff, and vision may carry a no_ci_reason exception."
  }
}

check "self_protection_enforced" {
  assert {
    condition     = contains(keys(var.repository_policies), "github-terraform")
    error_message = "tailrocks/github-terraform must remain in the managed repository inventory; every public inventory entry receives both rulesets."
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

check "merge_settings_overrides_explicit" {
  assert {
    condition = toset([
      for name, policy in var.repository_policies : name
      if policy.merge_settings != null
    ]) == toset(["termrock"])
    error_message = "Only termrock (merge commits, live settings) may override the merge policy with merge_settings."
  }
}

check "overrides_are_explicit" {
  assert {
    condition = alltrue([
      toset([for name, policy in var.repository_policies : name if !policy.protect_tags]) == toset(["termrock"]),
      toset([for name, policy in var.repository_policies : name if !policy.review_thread_resolution]) == toset(["termrock"]),
      toset([for name, policy in var.repository_policies : name if policy.required_check_source_id != null]) == toset(["termrock"]),
    ])
    error_message = "Only termrock (terminal-components-baseline) may skip protect-tags, skip review-thread resolution, or pin a required-check source."
  }
}

check "delete_branch_on_merge_mandate" {
  assert {
    condition = alltrue([
      for k, v in module.repository_policy.repository_settings : v.delete_branch_on_merge == true
      if var.repository_policies[k].merge_settings == null
    ])
    error_message = "All managed repositories without a merge_settings override must enforce delete_branch_on_merge = true."
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
      if var.repository_policies[k].merge_settings == null
    ])
    error_message = "All managed repositories without a merge_settings override must enforce canonical squash-only merge policy."
  }
}

check "thread_resolution_and_active_enforcement" {
  assert {
    condition = alltrue([
      for name, gate in module.repository_policy.ruleset_enforcement :
      gate.enforcement == "active" &&
      (!var.repository_policies[name].protect_tags || gate.tags_enforcement == "active") &&
      gate.required_review_thread_resolution == var.repository_policies[name].review_thread_resolution
    ])
    error_message = "All protect-main/protect-tags rulesets must enforce active, with review-thread resolution as configured per repository."
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

check "velnor_new_release_tags_reserved" {
  assert {
    condition = (
      toset(var.repository_policies["velnor-new"].tag_creation_rulesets["release-tags"].include) == toset([
        "refs/tags/rust-ci-v*", "refs/tags/velnor-ci-v*", "refs/tags/velnor-gen-v*",
      ]) &&
      length(var.repository_policies["velnor-new"].tag_creation_rulesets["release-tags"].bypass_user_ids) == 1
    )
    error_message = "tailrocks/velnor-new must keep the release-tags ruleset: rust-ci-v*, velnor-ci-v*, and velnor-gen-v* tags, created only by one bypass user (tailrocks/velnor-new#682)."
  }
}
