# Bootstrap Nonprod Build Project
module bootstrap-cloudbuild {
  source            = "github.com/kewei5zhang/terraform-gcp-module.git//bootstrap-cloudbuild/module?ref=dev-v0.0.1"
  build_project_id  = var.build_project_id
  env_names         = var.env_names
  substitution_vars = var.substitution_vars
  build_env         = var.build_env
}

# Create Module CI Cloudbuild trigger for unit-testing based on feature branch
resource google_cloudbuild_trigger module_dry_run {
  provider    = google-beta
  for_each    = fileset("../../${path.module}", "**")
  description = "module ${each.value} - dry run"
  project     = var.build_project_id
  github {
    owner = "kewei5zhang"
    name  = "terraform-gcp-module"
    push {
      branch = "feature/${dirname(each.value)}*"
    }
  }
  filename      = "cloudbuild-dry-run.yaml"
  substitutions = merge(var.substitution_vars, { _MODULE = each.value })
  included_files = [
    "${dirname(each.value)}/module/**",
  ]
}
