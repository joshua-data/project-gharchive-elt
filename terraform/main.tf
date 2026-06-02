terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }

  backend "gcs" {
    # bucket / prefix are passed via `terraform init -backend-config=...`
    # The state bucket itself cannot be managed by this terraform config
    # (chicken-and-egg). Create it once with the included bootstrap script,
    # which applies versioning + UBLA + public-access-prevention + lifecycle:
    #   PROJECT_ID=<id> REGION=<region> ./bootstrap.sh
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "this" {
  project_id = var.project_id
}
