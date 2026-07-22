terraform {
  required_version = ">= 1.7.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.8"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

provider "github" {
  owner = var.github_organization
  # When null, provider uses GITHUB_TOKEN / GITHUB_APP_* env (jackin standard).
  token = var.github_token != null ? var.github_token : null
}
