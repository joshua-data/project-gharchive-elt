output "project_id" {
  description = "Register this as GitHub Secret GCP_PROJECT_ID."
  value       = var.project_id
}

output "region" {
  description = "Register this as GitHub Secret GCP_REGION."
  value       = var.region
}

output "gharchive_bucket_name" {
  description = "GCS bucket holding gharchive Parquet files."
  value       = local.gharchive_bucket_name
}

output "artifact_repo_id" {
  description = "Full Artifact Registry repo path for docker push."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${local.artifact_repo_id}"
}

output "cloud_run_job_name" {
  description = "Cloud Run Job name; CI references this when deploying a new image."
  value       = local.cloud_run_job_name
}

output "ci_deployer_sa_email" {
  description = "Register this as GitHub Secret GCP_SA_EMAIL."
  value       = google_service_account.ci_deployer.email
}

output "runner_sa_email" {
  description = "Cloud Run Job runtime service account email."
  value       = google_service_account.runner.email
}

output "wif_provider_id" {
  description = "Register this as GitHub Secret GCP_WIF_PROVIDER."
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${local.wif_pool_id}/providers/${local.wif_provider_id}"
}

output "bq_dataset" {
  description = "BigQuery dataset holding the external tables over raw Parquet."
  value       = local.bq_dataset_id
}
