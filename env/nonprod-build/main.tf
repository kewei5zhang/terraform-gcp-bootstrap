# Bootstrap Nonprod Build Project
module bootstrap-cloudbuild {
  source            = "github.com/kewei5zhang/terraform-gcp-module.git//modules/bootstrap-cloudbuild/module?ref=1.0.8"
  build_project_id  = var.build_project_id
  env_names         = var.env_names
  substitution_vars = var.substitution_vars
  build_env         = var.build_env
}