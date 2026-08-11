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

variable "op_vault" {
  type        = string
  description = "1Password vault UUID or name used by op:// paths"
  default     = "TailRocks"
}

variable "secret_visibility" {
  type        = string
  description = "Org secret visibility: all, private, or selected"
  default     = "private"

  validation {
    condition     = contains(["all", "private", "selected"], var.secret_visibility)
    error_message = "secret_visibility must be one of: all, private, selected."
  }
}

variable "managed_repositories" {
  description = "Repositories that receive the TailRocks merge-policy standard (and rulesets when public)."
  type        = list(string)
  default = [
    "velnor",
    "velnor-apt",
    "velnor-actions",
    "tablerock",
    "velnor-actions-fixture",
    "holla",
    "termrock",
    "parallax",
    "tracing-request-level",
    "pg-bigdecimal",
    "holla-apt",
    "homebrew-holla",
    "parallax-telemetry-playground",
    "ruxel",
    "homebrew-tablerock",
    "schemalane",
    "homebrew-parallax",
    "tailrocks-gradle-conventions",
    "graphql-java-datetime",
    "jambalaya",
    "tailrocks-skills",
    "tailrocks-sqldiff",
    "github-terraform",
    "tailrocks-logo",
    "dumper",
    "pgquill",
    "renovate-rust",
    "review-crucible",
    "rust-best-practices",
  ]
}

variable "velnor_runner_group_repositories" {
  description = "Repositories allowed to schedule jobs on the velnor-trusted Actions runner group."
  type        = set(string)
  default = [
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
    condition     = length(setsubtract(var.velnor_runner_group_repositories, toset(var.managed_repositories))) == 0
    error_message = "velnor_runner_group_repositories must be a subset of managed_repositories."
  }
}

variable "ruleset_repositories" {
  description = "Public repositories that receive the protect-main and protect-tags rulesets. Kept explicit so for_each keys are known before import/apply."
  type        = list(string)
  default = [
    "velnor",
    "velnor-apt",
    "velnor-actions",
    "tablerock",
    "velnor-actions-fixture",
    "holla",
    "termrock",
    "parallax",
    "tracing-request-level",
    "pg-bigdecimal",
    "holla-apt",
    "homebrew-holla",
    "parallax-telemetry-playground",
    "ruxel",
    "homebrew-tablerock",
    "schemalane",
    "homebrew-parallax",
    "tailrocks-gradle-conventions",
    "graphql-java-datetime",
    "jambalaya",
    "tailrocks-skills",
    "dumper",
    "pgquill",
    "renovate-rust",
    "review-crucible",
    "rust-best-practices",
  ]

  validation {
    condition     = length(setsubtract(toset(var.ruleset_repositories), toset(var.managed_repositories))) == 0
    error_message = "ruleset_repositories must be a subset of managed_repositories."
  }
}

# Per-repository list of status check contexts that must pass before a PR
# can merge into the default branch. Context names are the bare check-run
# name field (not the `<workflow> / <job>` display string). Repos absent
# from this map have no required status checks yet.
variable "repo_required_status_checks" {
  description = "Map of repository name to required status check contexts for protect-main."
  type        = map(list(string))
  default = {
    tailrocks-skills = [
      "validate",
      "templates-macos",
    ]
  }
}
