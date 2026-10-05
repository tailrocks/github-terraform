# TailRocks organization resources remain here. Repository policy ownership for
# the 36 centrally managed repos moves to the ChainArgos control plane.

import {
  to = github_organization_settings.tailrocks
  id = "78806509"
}

import {
  to = github_actions_organization_permissions.tailrocks
  id = "tailrocks"
}

import {
  to = github_actions_organization_workflow_permissions.tailrocks
  id = "tailrocks"
}

import {
  to = github_actions_runner_group.velnor_trusted
  id = "3"
}

# These five repositories remain explicit local exceptions to central policy
# ownership; their current settings and rulesets are preserved as-is.

# Managed repository settings import

import {
  to = module.retained_policy_exceptions.github_repository.managed_settings["graphql-java-datetime"]
  id = "graphql-java-datetime"
}

import {
  to = module.retained_policy_exceptions.github_repository.managed_settings["jambalaya"]
  id = "jambalaya"
}

import {
  to = module.retained_policy_exceptions.github_repository.managed_settings["renovate-rust"]
  id = "renovate-rust"
}

import {
  to = module.retained_policy_exceptions.github_repository.managed_settings["tailrocks-logo"]
  id = "tailrocks-logo"
}

import {
  to = module.retained_policy_exceptions.github_repository.managed_settings["tailrocks-sqldiff"]
  id = "tailrocks-sqldiff"
}

# Existing protect-main ruleset import

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_main["graphql-java-datetime"]
  id = "graphql-java-datetime:19573065"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_main["jambalaya"]
  id = "jambalaya:19572993"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_main["renovate-rust"]
  id = "renovate-rust:20575222"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_main["tailrocks-logo"]
  id = "tailrocks-logo:24300482"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_main["tailrocks-sqldiff"]
  id = "tailrocks-sqldiff:24300485"
}

# Existing protect-tags ruleset import

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["graphql-java-datetime"]
  id = "graphql-java-datetime:19573031"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["jambalaya"]
  id = "jambalaya:19573044"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["renovate-rust"]
  id = "renovate-rust:20575267"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["tailrocks-logo"]
  id = "tailrocks-logo:24300484"
}

import {
  to = module.retained_policy_exceptions.github_repository_ruleset.protect_tags["tailrocks-sqldiff"]
  id = "tailrocks-sqldiff:24300486"
}
