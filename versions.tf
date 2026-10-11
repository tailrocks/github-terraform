# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_version = ">= 1.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }

    onepassword = {
      source  = "1password/onepassword"
      version = "~> 3.3"
    }
  }
}
