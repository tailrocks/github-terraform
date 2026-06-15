variable "github_organization" {
  type        = string
  description = "GitHub organization name for TailRocks"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT or GitHub App token with org admin scopes"
  sensitive   = true
}

variable "op_vault" {
  type        = string
  description = "1Password vault UUID or name used by op:// paths"
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
