resource "google_bigquery_dataset" "gharchive" {
  dataset_id  = local.bq_dataset_id
  location    = var.region
  description = "Dataset for gharchive data"
  labels      = local.common_labels
  depends_on  = [google_project_service.api_enabled]
}

resource "google_bigquery_table" "gharchive_events" {
  dataset_id          = local.bq_dataset_id
  table_id            = local.bq_table_id
  description         = "External table for gharchive events stored in GCS as Parquet files"
  deletion_protection = true

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    source_uris   = ["gs://${local.gharchive_bucket_name}/events/*.parquet"]
    hive_partitioning_options {
      mode              = "AUTO"
      source_uri_prefix = "gs://${local.gharchive_bucket_name}/events/"
    }
  }
}

resource "google_bigquery_dataset" "dw" {
  dataset_id  = local.bq_dw_dataset_id
  location    = var.region
  description = "Curated warehouse dataset built by dbt"
  labels      = local.common_labels
  depends_on  = [google_project_service.api_enabled]
}

resource "google_bigquery_dataset" "dw_dev" {
  dataset_id  = local.bq_dw_dev_dataset_id
  location    = var.region
  description = "Curated warehouse dataset built by dbt (dev environment)"
  labels      = local.common_labels
  depends_on  = [google_project_service.api_enabled]
}
