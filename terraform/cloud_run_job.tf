resource "google_cloud_run_v2_job" "gharchive" {
  name     = local.cloud_run_job_name
  location = var.region
  labels   = local.common_labels

  template {
    template {
      service_account = google_service_account.runner.email
      max_retries     = var.cloud_run_job_max_retries
      timeout         = var.cloud_run_job_timeout

      containers {
        image = local.placeholder_image

        env {
          name  = "GCS_RAW_BUCKET"
          value = local.gharchive_bucket_name
        }
        env {
          name  = "LAG_HOURS"
          value = tostring(var.lag_hours)
        }
        env {
          name  = "CATCHUP_HOURS"
          value = tostring(var.catchup_hours)
        }

        resources {
          limits = {
            cpu    = var.cloud_run_job_cpu
            memory = var.cloud_run_job_memory
          }
        }
      }
    }
  }

  lifecycle {
    # CI updates the container image; ignore drift on that field.
    ignore_changes = [template[0].template[0].containers[0].image]
  }

  depends_on = [
    google_project_service.api_enabled,
    google_storage_bucket_iam_member.runner_roles,
  ]
}
