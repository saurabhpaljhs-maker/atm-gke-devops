variable "project_id" {
  description = "GCP project ID jahan ATM cluster banega"
  type        = string
}

variable "region" {
  description = "GKE Autopilot region"
  type        = string
  default     = "asia-south1" # Mumbai region - India ke closest
}

variable "cluster_name" {
  description = "GKE cluster ka naam"
  type        = string
  default     = "atm-gke-cluster"
}
