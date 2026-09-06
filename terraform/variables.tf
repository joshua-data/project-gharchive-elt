variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Default GCP region for all regional resources"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in 'owner/name' form (used to lock down WIF)"
}

variable "lag_hours" {
  type        = number
  description = "How many hours behind UTC now to fetch in auto mode"
  default     = 1
  validation {
    condition     = var.lag_hours >= 0
    error_message = "lag_hours must be >= 0."
  }
}

variable "catchup_hours" {
  type        = number
  description = "Extra hours behind lag_hours to re-attempt on each scheduled run. Idempotent (skips hours with _SUCCESS marker), so cost is near-zero. Provides automatic gap recovery without a separate backfill job."
  default     = 3
  validation {
    condition     = var.catchup_hours >= 0
    error_message = "catchup_hours must be >= 0."
  }
}

variable "schedule_cron" {
  type        = string
  description = "Cron schedule for Cloud Scheduler"
  default     = "30 * * * *"
  validation {
    condition     = length(split(" ", trimspace(var.schedule_cron))) == 5
    error_message = "schedule_cron must be a 5-field cron expression."
  }
}

variable "scheduler_retry_count" {
  type        = number
  description = "Cloud Scheduler retry count on HTTP target failure. Recommended 0: scheduler retries can fire while a prior job is still running. Recovery is handled by catchup_hours and the source-level HTTP retry loop."
  default     = 0
  validation {
    condition     = var.scheduler_retry_count >= 0
    error_message = "scheduler_retry_count must be >= 0."
  }
}

variable "cloud_run_job_max_retries" {
  type        = number
  description = "Cloud Run Job task max retries on non-zero exit. Recommended 1: the source code already retries each HTTP request up to 5x, so a full task re-run rarely helps and doubles the cost."
  default     = 1
  validation {
    condition     = var.cloud_run_job_max_retries >= 0
    error_message = "cloud_run_job_max_retries must be >= 0."
  }
}

variable "cloud_run_job_timeout" {
  type        = string
  description = "Cloud Run Job task timeout (e.g. \"900s\")."
  default     = "900s"
}

variable "cloud_run_job_cpu" {
  type        = string
  description = "Cloud Run Job container CPU limit (e.g. \"1\")."
  default     = "1"
}

variable "cloud_run_job_memory" {
  type        = string
  description = "Cloud Run Job container memory limit (e.g. \"4Gi\"). The ingest job materializes a full GH Archive hour in memory, so this must exceed the hourly peak RSS. Up to \"4Gi\" is allowed with 1 vCPU."
  default     = "4Gi"
}
