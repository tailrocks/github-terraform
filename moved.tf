# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0

# Four repositories carry a -legacy suffix on GitHub. These blocks move their state
# entries to the matching inventory keys so that no resource is destroyed.
# Delete this file after the first apply that includes it.

moved {
  from = module.repository_policy.github_repository.managed_settings["homebrew-velnor"]
  to   = module.repository_policy.github_repository.managed_settings["homebrew-velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["homebrew-velnor"]
  to   = module.repository_policy.github_repository_ruleset.protect_main["homebrew-velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["homebrew-velnor"]
  to   = module.repository_policy.github_repository_ruleset.protect_tags["homebrew-velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository.managed_settings["velnor"]
  to   = module.repository_policy.github_repository.managed_settings["velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["velnor"]
  to   = module.repository_policy.github_repository_ruleset.protect_main["velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["velnor"]
  to   = module.repository_policy.github_repository_ruleset.protect_tags["velnor-legacy"]
}

moved {
  from = module.repository_policy.github_repository.managed_settings["velnor-actions-fixture"]
  to   = module.repository_policy.github_repository.managed_settings["velnor-actions-fixture-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["velnor-actions-fixture"]
  to   = module.repository_policy.github_repository_ruleset.protect_main["velnor-actions-fixture-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["velnor-actions-fixture"]
  to   = module.repository_policy.github_repository_ruleset.protect_tags["velnor-actions-fixture-legacy"]
}

moved {
  from = module.repository_policy.github_repository.managed_settings["velnor-apt"]
  to   = module.repository_policy.github_repository.managed_settings["velnor-apt-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_main["velnor-apt"]
  to   = module.repository_policy.github_repository_ruleset.protect_main["velnor-apt-legacy"]
}

moved {
  from = module.repository_policy.github_repository_ruleset.protect_tags["velnor-apt"]
  to   = module.repository_policy.github_repository_ruleset.protect_tags["velnor-apt-legacy"]
}
