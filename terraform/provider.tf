terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # State ko GCS bucket mein remote rakh rahe hain - team collaboration aur locking ke liye
  # NOTE: yeh bucket pehle manually ya bootstrap script se bana lena, tabhi backend init hoga
  backend "gcs" {
    bucket = "atm-project-tfstate-saurabh"
    prefix = "gke/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
