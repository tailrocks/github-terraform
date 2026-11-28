# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

locals {
  # The cncf/dco2 GitHub App that posts DCO. The only place the ID is written
  # outside the variables.tf defaults, which must be literals; the
  # repository_policies validations check every default against it.
  dco_app_id = 974774

  # Check templates for new inventory entries. Variable defaults must be
  # literals, so variables.tf keeps literal lists — copy from here when
  # adding a repo, and keep both in sync. Bespoke check lists stay allowed
  # with a comment citing the producing workflow.
  check_templates = {
    dco_policy_ci = ["DCO", "Policy", "ci-required"]
    dco_required  = ["DCO", "Required"]
    control       = ["Control / Required"]
    required_only = ["Required"]
    dco_only      = ["DCO"]
    policy        = ["Policy"]
  }
}
