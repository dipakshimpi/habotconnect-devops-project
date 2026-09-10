/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d0-raw-landing/main.tf
  Purpose: Creates the D0 Raw Landing bucket and ingestion IAM.

  Author: Dipak Shimpi
*/

resource "google_storage_bucket" "raw_landing" {
  name     = var.raw_bucket_name
  project  = var.project_id
  location = var.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
}

resource "google_storage_bucket_iam_member" "ingestion_object_creator" {
  bucket = google_storage_bucket.raw_landing.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${var.ingestion_service_account_email}"

  condition {
    title       = "Allow ingestion into raw objects"
    description = "Allows the ingestion service account to create objects in the D0 Raw Landing bucket."
    expression  = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.raw_landing.name}/objects/')"
  }
}