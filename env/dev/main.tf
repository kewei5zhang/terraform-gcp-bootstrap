# dev module
module dev {
  source            = "github.com/kewei5zhang/terraform-gcp-module.git//resource-gcs/module?ref=v1.0.3"
  bucket_name       = var.env_name
  build_env         = var.build_env
}

