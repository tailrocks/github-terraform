# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

# Managed repository settings + rulesets.
# Authoritative canonical module: modules/repository-policy
# Enforces squash-only merges, delete head branch, allow update branch,
# protect default branch + all tags with zero standing bypasses.

module "repository_policy" {
  source = "./modules/repository-policy"

  repository_policies = var.repository_policies
}

