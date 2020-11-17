# dev module
module dev {
  source          = "github.com/kewei5zhang/terraform-gcp-module.git//modules/resource-gcs/module?ref=1.0.6"
  project_id      = var.project_id
  bucket_name     = var.bucket_name
  region          = var.region
  force_destroy   = var.force_destroy
  storage_class   = var.storage_class
  versioning_enabled = var.versioning_enabled
}