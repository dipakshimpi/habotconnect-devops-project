/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: versions.tf
  Purpose: Defines required Terraform and provider versions.

  Author: Dipak Shimpi
  Contact: shimpidipak81@gmail.com
*/

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}