variable "repository_policies" {
  description = "Map of repository names to their visibility and required status checks"
  type = map(object({
    visibility      = string
    required_checks = list(string)
    no_ci_reason    = optional(string)
  }))

  validation {
    condition = alltrue([
      for name, config in var.repository_policies :
      contains(["public", "private"], config.visibility)
    ])
    error_message = "visibility must be either 'public' or 'private'."
  }

  validation {
    condition = alltrue([
      for name, config in var.repository_policies :
      length(config.required_checks) > 0
      ? (
        alltrue([for context in config.required_checks : trimspace(context) != ""]) &&
        config.no_ci_reason == null
      )
      : try(length(trimspace(config.no_ci_reason)) > 0, false)
    ])
    error_message = "Each repository must have non-empty required status contexts or a non-empty no_ci_reason for its explicit no-CI exception."
  }
}
