/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d0-raw-landing/variables.tf
  Purpose: Defines inputs required by the D0 Raw Landing module.

  Author: Dipak Shimpi
*/

variable "project_id" {
  description = "Google Cloud project ID used by the D0 module."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the D0 bucket."
  type        = string
}

variable "raw_bucket_name" {
  description = "Name of the D0 Raw Landing bucket."
  type        = string
}

variable "ingestion_service_account_email" {
  description = "Email of the service account used for D0 ingestion."
  type        = string
}