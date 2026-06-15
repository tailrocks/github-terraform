terraform {
  required_version = ">= 1.7.0"
}

# TODO: initialize once you are ready for remote state.
# Example with an existing bucket/back-end:
# terraform {
#   backend "s3" {
#     bucket  = "tailrocks-terraform-state"
#     key     = "github/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }
