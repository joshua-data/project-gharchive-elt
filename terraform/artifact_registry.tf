resource "google_artifact_registry_repository" "gharchive" {
  location      = var.region
  repository_id = local.artifact_repo_id
  description   = "Container images repository for gharchive Cloud Run Job"
  format        = "DOCKER"
  labels        = local.common_labels

  cleanup_policies {
    id     = "keep-recent-shas"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "86400s"
    }
  }

  depends_on = [google_project_service.api_enabled]
}
