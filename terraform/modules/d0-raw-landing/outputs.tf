/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d0-raw-landing/outputs.tf
  Purpose: Exposes D0 Raw Landing resource values.

  Author: Dipak Shimpi
*/

output "bucket_name" {
  description = "Name of the D0 Raw Landing bucket."
  value       = google_storage_bucket.raw_landing.name
}

output "bucket_url" {
  description = "URL of the D0 Raw Landing bucket."
  value       = google_storage_bucket.raw_landing.url
}