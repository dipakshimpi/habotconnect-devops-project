/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d1-staged-enforced/outputs.tf
  Purpose: Exposes important D1 resource values.

  Author: Dipak Shimpi
*/

output "dataset_id" {
  description = "ID of the D1 Staged/Enforced BigQuery dataset."
  value       = google_bigquery_dataset.d1_staged_enforced.dataset_id
}

output "table_id" {
  description = "ID of the D1 student onboarding table."
  value       = google_bigquery_table.student_onboarding.table_id
}