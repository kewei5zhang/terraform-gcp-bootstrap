# Bootstrap Nonprod Build Project
terraform {
  backend "local" {}
}

module nonprod-build {
  source            = "github.com/kewei5zhang/terraform-gcp-module//bootstrap-cloudbuild?ref=master"
  build_project_id  = var.build_project_id
  env_names         = var.env_names
  substitution_vars = var.substitution_vars
  build_env         = var.build_env
}

