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
