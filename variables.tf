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
  description = "TailRocks policy exceptions retained locally; the central control plane owns all other TailRocks repositories."
  type = map(object({
    disposition     = string
    visibility      = string
    required_checks = list(string)
  }))

  validation {
    condition     = toset(keys(var.managed_repositories)) == toset(["renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"])
    error_message = "Only renovate-rust, tailrocks-logo, and tailrocks-sqldiff remain in the TailRocks policy root; all other repository policies are owned by the central control plane."
  }

  default = {
    "renovate-rust" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-logo" = {
      disposition     = "FullRuleset"
      visibility      = "public"
      required_checks = []
    }
    "tailrocks-sqldiff" = {
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


}
