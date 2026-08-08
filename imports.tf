# Import existing GitHub repositories into managed_settings.
# Safe to keep: OpenTofu no-ops imports already present in state.

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
  to = github_repository.managed_settings["velnor"]
  id = "velnor"
}

import {
  to = github_repository.managed_settings["velnor-actions"]
  id = "velnor-actions"
}

import {
  to = github_repository.managed_settings["velnor-apt"]
  id = "velnor-apt"
}

import {
  to = github_repository.managed_settings["tablerock"]
  id = "tablerock"
}

import {
  to = github_repository.managed_settings["velnor-actions-fixture"]
  id = "velnor-actions-fixture"
}

import {
  to = github_repository.managed_settings["holla"]
  id = "holla"
}

import {
  to = github_repository.managed_settings["termrock"]
  id = "termrock"
}

import {
  to = github_repository.managed_settings["parallax"]
  id = "parallax"
}

import {
  to = github_repository.managed_settings["tracing-request-level"]
  id = "tracing-request-level"
}

import {
  to = github_repository.managed_settings["pg-bigdecimal"]
  id = "pg-bigdecimal"
}

import {
  to = github_repository.managed_settings["holla-apt"]
  id = "holla-apt"
}

import {
  to = github_repository.managed_settings["homebrew-holla"]
  id = "homebrew-holla"
}

import {
  to = github_repository.managed_settings["parallax-telemetry-playground"]
  id = "parallax-telemetry-playground"
}

import {
  to = github_repository.managed_settings["ruxel"]
  id = "ruxel"
}

import {
  to = github_repository.managed_settings["homebrew-tablerock"]
  id = "homebrew-tablerock"
}

import {
  to = github_repository.managed_settings["schemalane"]
  id = "schemalane"
}

import {
  to = github_repository.managed_settings["homebrew-parallax"]
  id = "homebrew-parallax"
}

import {
  to = github_repository.managed_settings["tailrocks-gradle-conventions"]
  id = "tailrocks-gradle-conventions"
}

import {
  to = github_repository.managed_settings["graphql-java-datetime"]
  id = "graphql-java-datetime"
}

import {
  to = github_repository.managed_settings["jambalaya"]
  id = "jambalaya"
}

import {
  to = github_repository.managed_settings["tailrocks-skills"]
  id = "tailrocks-skills"
}

import {
  to = github_repository.managed_settings["tailrocks-sqldiff"]
  id = "tailrocks-sqldiff"
}

import {
  to = github_repository.managed_settings["github-terraform"]
  id = "github-terraform"
}

import {
  to = github_repository.managed_settings["tailrocks-logo"]
  id = "tailrocks-logo"
}

import {
  to = github_repository.managed_settings["dumper"]
  id = "dumper"
}

import {
  to = github_repository.managed_settings["pgquill"]
  id = "pgquill"
}

import {
  to = github_repository.managed_settings["renovate-rust"]
  id = "renovate-rust"
}

import {
  to = github_repository.managed_settings["review-crucible"]
  id = "review-crucible"
}

import {
  to = github_repository.managed_settings["rust-best-practices"]
  id = "rust-best-practices"
}

import {
  to = github_repository_ruleset.protect_main["velnor"]
  id = "velnor:19573071"
}

import {
  to = github_repository_ruleset.protect_tags["velnor"]
  id = "velnor:19573007"
}

import {
  to = github_repository_ruleset.protect_main["velnor-apt"]
  id = "velnor-apt:19572991"
}

import {
  to = github_repository_ruleset.protect_tags["velnor-apt"]
  id = "velnor-apt:19572989"
}

import {
  to = github_repository_ruleset.protect_main["tablerock"]
  id = "tablerock:19573034"
}

import {
  to = github_repository_ruleset.protect_tags["tablerock"]
  id = "tablerock:19573013"
}

import {
  to = github_repository_ruleset.protect_main["velnor-actions-fixture"]
  id = "velnor-actions-fixture:19572977"
}

import {
  to = github_repository_ruleset.protect_tags["velnor-actions-fixture"]
  id = "velnor-actions-fixture:19572996"
}

import {
  to = github_repository_ruleset.protect_main["holla"]
  id = "holla:19573066"
}

import {
  to = github_repository_ruleset.protect_tags["holla"]
  id = "holla:19573079"
}

import {
  to = github_repository_ruleset.protect_main["termrock"]
  id = "termrock:19573043"
}

import {
  to = github_repository_ruleset.protect_tags["termrock"]
  id = "termrock:19573026"
}

import {
  to = github_repository_ruleset.protect_main["parallax"]
  id = "parallax:19573072"
}

import {
  to = github_repository_ruleset.protect_tags["parallax"]
  id = "parallax:19572998"
}

import {
  to = github_repository_ruleset.protect_main["tracing-request-level"]
  id = "tracing-request-level:19573037"
}

import {
  to = github_repository_ruleset.protect_tags["tracing-request-level"]
  id = "tracing-request-level:19573006"
}

import {
  to = github_repository_ruleset.protect_main["pg-bigdecimal"]
  id = "pg-bigdecimal:19573069"
}

import {
  to = github_repository_ruleset.protect_tags["pg-bigdecimal"]
  id = "pg-bigdecimal:19572980"
}

import {
  to = github_repository_ruleset.protect_main["holla-apt"]
  id = "holla-apt:19573059"
}

import {
  to = github_repository_ruleset.protect_tags["holla-apt"]
  id = "holla-apt:19573011"
}

import {
  to = github_repository_ruleset.protect_main["homebrew-holla"]
  id = "homebrew-holla:19573039"
}

import {
  to = github_repository_ruleset.protect_tags["homebrew-holla"]
  id = "homebrew-holla:19573001"
}

import {
  to = github_repository_ruleset.protect_main["parallax-telemetry-playground"]
  id = "parallax-telemetry-playground:19573032"
}

import {
  to = github_repository_ruleset.protect_tags["parallax-telemetry-playground"]
  id = "parallax-telemetry-playground:19573003"
}

import {
  to = github_repository_ruleset.protect_main["ruxel"]
  id = "ruxel:19573057"
}

import {
  to = github_repository_ruleset.protect_tags["ruxel"]
  id = "ruxel:19572976"
}

import {
  to = github_repository_ruleset.protect_main["homebrew-tablerock"]
  id = "homebrew-tablerock:19572984"
}

import {
  to = github_repository_ruleset.protect_tags["homebrew-tablerock"]
  id = "homebrew-tablerock:19573016"
}

import {
  to = github_repository_ruleset.protect_main["schemalane"]
  id = "schemalane:19573073"
}

import {
  to = github_repository_ruleset.protect_tags["schemalane"]
  id = "schemalane:19572987"
}

import {
  to = github_repository_ruleset.protect_main["homebrew-parallax"]
  id = "homebrew-parallax:19573077"
}

import {
  to = github_repository_ruleset.protect_tags["homebrew-parallax"]
  id = "homebrew-parallax:19573018"
}

import {
  to = github_repository_ruleset.protect_main["tailrocks-gradle-conventions"]
  id = "tailrocks-gradle-conventions:19573041"
}

import {
  to = github_repository_ruleset.protect_tags["tailrocks-gradle-conventions"]
  id = "tailrocks-gradle-conventions:19573027"
}

import {
  to = github_repository_ruleset.protect_main["graphql-java-datetime"]
  id = "graphql-java-datetime:19573065"
}

import {
  to = github_repository_ruleset.protect_tags["graphql-java-datetime"]
  id = "graphql-java-datetime:19573031"
}

import {
  to = github_repository_ruleset.protect_main["jambalaya"]
  id = "jambalaya:19572993"
}

import {
  to = github_repository_ruleset.protect_tags["jambalaya"]
  id = "jambalaya:19573044"
}

import {
  to = github_repository_ruleset.protect_main["tailrocks-skills"]
  id = "tailrocks-skills:19572990"
}

import {
  to = github_repository_ruleset.protect_tags["tailrocks-skills"]
  id = "tailrocks-skills:19572983"
}

import {
  to = github_repository_ruleset.protect_main["dumper"]
  id = "dumper:20575266"
}

import {
  to = github_repository_ruleset.protect_tags["dumper"]
  id = "dumper:20575199"
}

import {
  to = github_repository_ruleset.protect_main["pgquill"]
  id = "pgquill:20575210"
}

import {
  to = github_repository_ruleset.protect_tags["pgquill"]
  id = "pgquill:20575190"
}

import {
  to = github_repository_ruleset.protect_main["renovate-rust"]
  id = "renovate-rust:20575222"
}

import {
  to = github_repository_ruleset.protect_tags["renovate-rust"]
  id = "renovate-rust:20575267"
}

import {
  to = github_repository_ruleset.protect_main["review-crucible"]
  id = "review-crucible:20575194"
}

import {
  to = github_repository_ruleset.protect_tags["review-crucible"]
  id = "review-crucible:20575265"
}

import {
  to = github_repository_ruleset.protect_main["rust-best-practices"]
  id = "rust-best-practices:20575216"
}

import {
  to = github_repository_ruleset.protect_tags["rust-best-practices"]
  id = "rust-best-practices:20575263"
}

import {
  to = github_repository_ruleset.protect_main["velnor-actions"]
  id = "velnor-actions:20575205"
}

import {
  to = github_repository_ruleset.protect_tags["velnor-actions"]
  id = "velnor-actions:20575183"
}
