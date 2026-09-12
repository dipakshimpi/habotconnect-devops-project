/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: variables.tf
  Purpose: Defines configurable Terraform inputs for the secure staging
           infrastructure.

  Author: Dipak Shimpi
  Contact: shimpidipak81@gmail.com
*/

variable "project_id" {
  description = "Google Cloud project ID where the Habot Connect staging infrastructure will be provisioned."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The Google Cloud project ID must contain 6 to 30 lowercase letters, numbers, or hyphens, start with a lowercase letter, and end with a lowercase letter or number."
  }
}

variable "region" {
  description = "Google Cloud region used for regional resources."
  type        = string
  default     = "asia-south1"
}

variable "raw_bucket_name" {
  description = "Globally unique Google Cloud Storage bucket name for the D0 Raw Landing layer."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset identifier for the D1 Staged/Enforced layer."
  type        = string
  default     = "d1_staged_enforced"
}

variable "table_id" {
  description = "BigQuery table identifier for validated student onboarding records."
  type        = string
  default     = "student_onboarding"
}

variable "app_engine_location" {
  description = "Google App Engine application location."
  type        = string
  default     = "asia-south1"
}