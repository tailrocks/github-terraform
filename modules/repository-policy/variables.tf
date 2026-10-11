# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

variable "repository_policies" {
  description = "Map of repository names to their protection policy configurations"
  type = map(object({
    visibility      = string # "public" | "private"
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
      (
        length(config.required_checks) > 0
        && alltrue([for c in config.required_checks : trimspace(c) != ""])
        && config.no_ci_reason == null
        ) || (
        length(config.required_checks) == 0
        && config.no_ci_reason != null
        && trimspace(config.no_ci_reason) != ""
      )
    ])
    error_message = "Each entry must satisfy: non-empty blank-free required_checks with null no_ci_reason, XOR empty checks with non-empty no_ci_reason."
  }
}
