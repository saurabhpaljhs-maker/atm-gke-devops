resource "google_artifact_registry_repository" "atm_repo" {
  location      = var.region
  repository_id = "atm-project-repo"
  description   = "ATM-Project docker images - GCP native registry replacing DockerHub"
  format        = "DOCKER"
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.atm_repo.repository_id}"
}
