resource "google_cloud_scheduler_job" "gharchive" {
  name        = local.scheduler_job_id
  region      = var.region
  schedule    = var.schedule_cron
  time_zone   = local.scheduler_timezone
  description = "Triggers gharchive Cloud Run Job"

  retry_config {
    retry_count          = var.scheduler_retry_count
    min_backoff_duration = "30s"
    max_backoff_duration = "300s"
    max_doublings        = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${local.cloud_run_job_name}:run"
    oauth_token { service_account_email = google_service_account.scheduler.email }
  }

  depends_on = [
    google_project_service.api_enabled,
    google_project_iam_member.scheduler_roles,
  ]
}
