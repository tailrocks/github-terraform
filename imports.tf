# Import existing GitHub repositories into managed_settings.
# Safe to keep: OpenTofu no-ops imports already present in state.

import {
  to = github_repository.managed_settings["velnor"]
  id = "velnor"
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
  to = github_repository.managed_settings["tailrocks-marketplace"]
  id = "tailrocks-marketplace"
}

import {
  to = github_repository.managed_settings["tailrocks-sqldiff"]
  id = "tailrocks-sqldiff"
}
