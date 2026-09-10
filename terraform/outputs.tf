/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: outputs.tf
  Purpose: Exposes important infrastructure values after Terraform
           provisioning.

  Author: Dipak Shimpi
*/

# ------------------------------------------------------------
# D0 Raw Landing
# ------------------------------------------------------------

output "raw_landing_bucket_name" {
  description = "Name of the D0 Raw Landing Cloud Storage bucket."
  value       = module.d0_raw_landing.bucket_name
}

output "raw_landing_bucket_url" {
  description = "Google Cloud Storage URL for the D0 Raw Landing bucket."
  value       = module.d0_raw_landing.bucket_url
}

# ------------------------------------------------------------
# D1 Staged/Enforced
# ------------------------------------------------------------

output "d1_dataset_id" {
  description = "BigQuery dataset ID for the D1 Staged/Enforced layer."
  value       = module.d1_staged_enforced.dataset_id
}

output "d1_table_id" {
  description = "BigQuery table ID for validated student onboarding data."
  value       = module.d1_staged_enforced.table_id
}

# ------------------------------------------------------------
# Service Account Identities
# ------------------------------------------------------------

output "ingestion_service_account_email" {
  description = "Email address of the service account used for D0 ingestion."
  value       = google_service_account.ingestion.email
}

output "analytics_service_account_email" {
  description = "Email address of the service account used for D1 analytics."
  value       = google_service_account.analytics.email
}