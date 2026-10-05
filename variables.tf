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
  description = "Authoritative inventory of managed repositories and their visibility and check policy."
  type = map(object({
    visibility      = string
    required_checks = list(string)
    no_ci_reason    = optional(string)
  }))

  validation {
    condition = alltrue([
      for repo in values(var.managed_repositories) :
      contains(["public", "private"], repo.visibility)
    ])
    error_message = "Each managed repository visibility must be either public or private."
  }

  validation {
    condition = alltrue([
      for repo in values(var.managed_repositories) :
      length(repo.required_checks) > 0
      ? (
        alltrue([for context in repo.required_checks : trimspace(context) != ""]) &&
        repo.no_ci_reason == null
      )
      : try(length(trimspace(repo.no_ci_reason)) > 0, false)
    ])
    error_message = "Each repository must declare non-empty required checks or a non-empty no_ci_reason for an explicit no-CI exception."
  }

  default = {
    "cloudflare-tofu" = {
      visibility      = "public"
      required_checks = ["DCO"]
    }
    "github-terraform" = {
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "graphql-java-datetime" = {
      visibility      = "public"
      required_checks = ["Policy"]
    }
    "holla" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "holla-apt" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-holla" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-parallax" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-ruxel" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-tablerock" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "homebrew-velnor" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "jambalaya" = {
      visibility      = "public"
      required_checks = ["Control / Required"]
    }
    "parallax" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "parallax-telemetry-playground" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "pg-bigdecimal" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "pgquill" = {
      visibility      = "public"
      required_checks = ["Control / Required"]
    }
    "renovate-rust" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow emits a status context; DCO app results are not a CI check."
    }
    "ruxel" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "schemalane" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tablerock" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tailrocks-code-quality-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-gradle-conventions" = {
      visibility      = "public"
      required_checks = ["Control / Required"]
    }
    "tailrocks-logo" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
    }
    "tailrocks-macos-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-open-source-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-pull-request-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-roadmap-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-rust-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-skill-authoring-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "tailrocks-skills" = {
      visibility      = "public"
      required_checks = ["DCO"]
    }
    "tailrocks-sqldiff" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
    }
    "tailrocks-typescript-skills" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "terminal-components-claude" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "termpane" = {
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "termrock" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tracing-request-level" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "tui-snap" = {
      visibility      = "public"
      required_checks = ["DCO", "Required"]
    }
    "velnor" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-actions-fixture" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-apt" = {
      visibility      = "public"
      required_checks = ["DCO", "Policy", "ci-required"]
    }
    "velnor-new" = {
      visibility      = "public"
      required_checks = ["Required"]
    }
    "vision" = {
      visibility      = "public"
      required_checks = []
      no_ci_reason    = "No CI workflow currently emits a status context."
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
