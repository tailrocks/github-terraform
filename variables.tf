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
    "tailrocks-marketplace",
    "tailrocks-sqldiff",
  ]
}

# Per-repository list of status check contexts that must pass before a PR
# can merge into the default branch. Context names are the bare check-run
# name field (not the `<workflow> / <job>` display string). Repos absent
# from this map have no required status checks yet.
variable "repo_required_status_checks" {
  description = "Map of repository name to required status check contexts for protect-main."
  type        = map(list(string))
  default     = {}
}
