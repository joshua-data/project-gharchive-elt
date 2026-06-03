# =============================================================================
# Cloud Scheduler invoker SA
# — calls the Cloud Run Job execute API.
# =============================================================================
resource "google_service_account" "scheduler" {
  account_id   = local.scheduler_sa_id
  display_name = "gharchive Cloud Scheduler invoker"
  depends_on   = [google_project_service.api_enabled]
}

resource "google_project_iam_member" "scheduler_roles" {
  for_each = toset(local.scheduler_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

# =============================================================================
# Cloud Run Job runtime SA
# — gharchive container runs as this identity.
# =============================================================================
resource "google_service_account" "runner" {
  account_id   = local.runner_sa_id
  display_name = "gharchive Cloud Run Job runtime"
  depends_on   = [google_project_service.api_enabled]
}

resource "google_storage_bucket_iam_member" "runner_roles" {
  for_each = toset(local.runner_sa_roles)
  bucket   = local.gharchive_bucket_name
  role     = each.value
  member   = "serviceAccount:${google_service_account.runner.email}"
}

# =============================================================================
# CI deployer SA
# — impersonated by GitHub Actions via WIF.
# =============================================================================
resource "google_service_account" "ci_deployer" {
  account_id   = local.ci_deployer_sa_id
  display_name = "gharchive GitHub Actions CI deployer (impersonated via WIF)"
  depends_on   = [google_project_service.api_enabled]
}

resource "google_project_iam_member" "ci_deployer_roles" {
  for_each = toset(local.ci_deployer_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_storage_bucket_iam_member" "ci_deployer_tfstate_bucket_roles" {
  bucket = local.tfstate_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_storage_bucket_iam_member" "ci_deployer_gharchive_bucket_roles" {
  bucket     = local.gharchive_bucket_name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.ci_deployer.email}"
  depends_on = [google_storage_bucket.gharchive]
}

resource "google_service_account_iam_member" "ci_deployer_acts_as_runner" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_project_iam_member" "ci_deployer_bq_project_roles" {
  for_each = toset(local.ci_deployer_bq_project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_bigquery_dataset_iam_member" "ci_deployer_bq_dataset_roles" {
  for_each   = toset(local.ci_deployer_bq_dataset_roles)
  dataset_id = local.bq_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_bigquery_dataset_iam_member" "ci_deployer_bq_dw_dataset_roles" {
  for_each   = toset(local.ci_deployer_bq_dataset_roles)
  dataset_id = local.bq_dw_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_bigquery_dataset_iam_member" "ci_deployer_bq_dw_dev_dataset_roles" {
  for_each   = toset(local.ci_deployer_bq_dataset_roles)
  dataset_id = local.bq_dw_dev_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.ci_deployer.email}"
}

# =============================================================================
# dbt runner SA
# — impersonated by GitHub Actions via WIF.
# =============================================================================
resource "google_service_account" "dbt_runner" {
  account_id   = local.dbt_runner_sa_id
  display_name = "gharchive GitHub Actions CI dbt runner (impersonated via WIF)"
  depends_on   = [google_project_service.api_enabled]
}

resource "google_project_iam_member" "dbt_runner_bq_project_roles" {
  for_each = toset(local.dbt_runner_bq_project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.dbt_runner.email}"
}

resource "google_bigquery_dataset_iam_member" "dbt_runner_bq_dataset_roles" {
  for_each   = toset(local.dbt_runner_bq_dataset_roles)
  dataset_id = local.bq_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.dbt_runner.email}"
}

resource "google_bigquery_dataset_iam_member" "dbt_runner_bq_dw_dataset_roles" {
  for_each   = toset(local.dbt_runner_bq_dw_dataset_roles)
  dataset_id = local.bq_dw_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.dbt_runner.email}"
}

resource "google_bigquery_dataset_iam_member" "dbt_runner_bq_dw_dev_dataset_roles" {
  for_each   = toset(local.dbt_runner_bq_dw_dev_dataset_roles)
  dataset_id = local.bq_dw_dev_dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.dbt_runner.email}"
}
