# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

locals {
  # Check templates for new inventory entries. Variable defaults must be
  # literals, so variables.tf keeps literal lists — copy from here when
  # adding a repo, and keep both in sync. Bespoke check lists stay allowed
  # with a comment citing the producing workflow.
  check_templates = {
    dco_policy_ci = ["DCO", "Policy", "ci-required"]
    control       = ["Control / Required"]
    required_only = ["Required"]
    dco_only      = ["DCO"]
    policy        = ["Policy"]
  }
}
