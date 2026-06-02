locals {
  gharchive_bucket_name = "${var.project_id}-gharchive"
  tfstate_bucket_name   = "${var.project_id}-gharchive-tfstate"
  artifact_repo_id      = "gharchive"

  wif_pool_id     = "github-pool"
  wif_provider_id = "github-provider"

  cloud_run_job_name = "gharchive"
  scheduler_job_id   = "gharchive"
  scheduler_timezone = "Etc/UTC"

  bq_dataset_id = "raw__gharchive"
  bq_table_id   = "ext__events"

  gcs_nearline_age_days = 30
  gcs_coldline_age_days = 90
  gcs_delete_age_days   = 180
  gcs_soft_delete_secs  = 7 * 24 * 60 * 60

  scheduler_sa_id   = "gharchive-invoker"
  runner_sa_id      = "gharchive-runner"
  ci_deployer_sa_id = "gharchive-ci-deployer"

  scheduler_sa_roles = ["roles/run.invoker"]
  runner_sa_roles    = ["roles/storage.objectCreator"]
  ci_deployer_sa_roles = [
    "roles/cloudscheduler.admin",
    "roles/artifactregistry.admin",
    "roles/run.developer",
  ]
  ci_deployer_bq_dataset_roles = ["roles/bigquery.dataOwner"]
  ci_deployer_bq_project_roles = ["roles/bigquery.jobUser"]

  placeholder_image = "us-docker.pkg.dev/cloudrun/container/job:latest"

  common_labels = {
    project    = "gharchive"
    managed_by = "terraform"
  }
}
