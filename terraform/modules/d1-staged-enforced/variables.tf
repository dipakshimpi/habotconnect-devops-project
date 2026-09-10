/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d1-staged-enforced/variables.tf
  Purpose: Defines inputs required by the D1 Staged/Enforced module.

  Author: Dipak Shimpi
*/

variable "project_id" {
  description = "Google Cloud project ID used by the D1 module."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the D1 dataset."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID for the D1 Staged/Enforced layer."
  type        = string
}

variable "table_id" {
  description = "BigQuery table ID for validated student onboarding data."
  type        = string
}

variable "analytics_service_account_email" {
  description = "Email of the service account used for analytics access."
  type        = string
}