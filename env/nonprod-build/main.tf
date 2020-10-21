# Bootstrap Nonprod Build Project
module nonprod-build {
  source            = "https://github.com/kewei5zhang/terraform-gcp-module.git//bootstrap-cloudbuild?ref=master"
  build_project_id  = var.build_project_id
  env_names         = var.env_names
  substitution_vars = var.substitution_vars
  build_env         = var.build_env
}

