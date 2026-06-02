resource "google_storage_bucket" "gharchive" {
  name                        = local.gharchive_bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels                      = local.common_labels

  versioning { enabled = false }
  soft_delete_policy { retention_duration_seconds = local.gcs_soft_delete_secs }

  lifecycle_rule {
    condition { age = local.gcs_nearline_age_days }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  lifecycle_rule {
    condition { age = local.gcs_coldline_age_days }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  lifecycle_rule {
    condition { age = local.gcs_delete_age_days }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.api_enabled]
}
