# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

variable "repository_policies" {
  description = "Map of repository names to their protection policy configurations"
  type = map(object({
    visibility      = string # "public" | "private"
    required_checks = list(string)
    no_ci_reason    = optional(string)
    # Archived repositories are read-only on GitHub: their settings are not managed
    # and only their rulesets are tracked.
    archived = optional(bool, false)
    # Require branches to be up to date with the default branch before merging.
    strict_required_status_checks = optional(bool, false)
    # Also block moving existing tags (the update rule) in protect-tags.
    protect_tags_update = optional(bool, false)
    # Extra tag rulesets, keyed by ruleset name, that restrict tag creation for the
    # include patterns to the listed user IDs.
    tag_creation_rulesets = optional(map(object({
      include         = list(string)
      bypass_user_ids = list(number)
    })), {})
    # Merge queue on the default branch. null (the default) leaves the queue off.
    merge_queue = optional(object({
      grouping_strategy                 = string
      max_entries_to_build              = number
      max_entries_to_merge              = number
      min_entries_to_merge              = number
      min_entries_to_merge_wait_minutes = number
      check_response_timeout_minutes    = number
      merge_method                      = string
    }))
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
