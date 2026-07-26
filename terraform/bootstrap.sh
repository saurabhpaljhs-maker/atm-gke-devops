#!/bin/bash
# Isse Cloud Shell mein sabse pehle run karna hai, terraform init se pehle.
# Kaam: required APIs enable karna + remote state ke liye GCS bucket banana.

set -e

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="atm-project-tfstate-saurabh"
REGION="asia-south1"

echo ">> Enabling required GCP APIs (thoda time lagega, ~1-2 min)..."
gcloud services enable \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  compute.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project="${PROJECT_ID}"

echo ">> Creating GCS bucket for Terraform remote state..."
# agar bucket already exist karta hai toh yeh command error dega, ignore kar sakte
gsutil mb -l "${REGION}" "gs://${BUCKET_NAME}" || echo "Bucket already exists, skipping."

# state file ke accidental delete se bachne ke liye versioning on karo
gsutil versioning set on "gs://${BUCKET_NAME}"

echo ">> Bootstrap done. Project ID: ${PROJECT_ID}"
echo ">> Ab terraform init/apply chala sakte ho -var=\"project_id=${PROJECT_ID}\""
