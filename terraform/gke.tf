resource "google_container_cluster" "atm_cluster" {
  name     = var.cluster_name
  location = var.region

  # Autopilot mode - Google khud nodes manage karega, humein sirf app deploy karni hai
  # Fast setup + minimal ops overhead, banking POC/demo ke liye perfect fit
  enable_autopilot = true

  # IMPORTANT: default true hota hai, isse false rakho warna terraform destroy fail hoga
  # aur cluster manually delete karna padega console se
  deletion_protection = false

  # default VPC use kar rahe hain speed ke liye - production mein custom VPC banate
  # (jaisa AWS wale version mein tha), lekin demo/interview scope ke liye yeh sufficient hai
  network    = "default"
  subnetwork = "default"

  release_channel {
    channel = "REGULAR"
  }
}

output "cluster_name" {
  value = google_container_cluster.atm_cluster.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.atm_cluster.endpoint
  sensitive = true
}
