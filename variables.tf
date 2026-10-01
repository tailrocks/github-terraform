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

variable "secret_visibility" {
  type        = string
  description = "Fallback org secret visibility when an entry omits it: all, private, or selected. All managed repos are public, so private hides a secret from everywhere; prefer explicit per-entry visibility."
  default     = "selected"

  validation {
    condition     = contains(["all", "private", "selected"], var.secret_visibility)
    error_message = "secret_visibility must be one of: all, private, selected."
  }
}

variable "managed_repositories" {
  description = "Authoritative inventory of managed repositories and their protection dispositions."
  type = map(object({
    disposition     = string
    visibility      = string
    required_checks = list(string)
  }))
  default = {
    "cloudflare-tofu" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO"]
    }
    "github-terraform" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "graphql-java-datetime" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["Policy"]
    }
    "holla" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "holla-apt" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-holla" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-parallax" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-ruxel" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-tablerock" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-velnor" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "jambalaya" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "parallax" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "parallax-telemetry-playground" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "pg-bigdecimal" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "pgquill" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "renovate-rust" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "ruxel" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "schemalane" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tablerock" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tailrocks-code-quality-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-gradle-conventions" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-logo" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-macos-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-open-source-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-pull-request-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-roadmap-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-rust-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-skill-authoring-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO"]
    }
    "tailrocks-sqldiff" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-typescript-skills" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "terminal-components-claude" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "termpane" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "termrock" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tracing-request-level" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tui-snap" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "velnor" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-actions-fixture" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-apt" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-new" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "vision" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
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
    "velnor",
    "velnor-actions-fixture",
    "velnor-apt",
  ]

  validation {
    condition     = length(setsubtract(var.velnor_runner_group_repositories, keys(var.managed_repositories))) == 0
    error_message = "velnor_runner_group_repositories must be a subset of managed_repositories."
  }
}
