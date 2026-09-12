/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: main.tf
  Purpose: Defines shared GCP resources and connects the infrastructure modules.

  Author: Dipak Shimpi
*/

# ------------------------------------------------------------
# Required Google Cloud APIs
# ------------------------------------------------------------

resource "google_project_service" "required_apis" {
  for_each = toset([
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "iam.googleapis.com",
    "appengine.googleapis.com",
    "pubsub.googleapis.com",
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# ------------------------------------------------------------
# Ingestion Service Account
# ------------------------------------------------------------

resource "google_service_account" "ingestion" {
  account_id   = "habot-ingestion"
  display_name = "Habot Connect Ingestion Service Account"

  depends_on = [
    google_project_service.required_apis["iam.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# Analytics Service Account
# ------------------------------------------------------------

resource "google_service_account" "analytics" {
  account_id   = "habot-analytics"
  display_name = "Habot Connect Analytics Service Account"

  depends_on = [
    google_project_service.required_apis["iam.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# Backend Service Account
# ------------------------------------------------------------

resource "google_service_account" "backend" {
  account_id   = "habot-backend"
  display_name = "Habot Connect Django Backend Service Account"

  depends_on = [
    google_project_service.required_apis["iam.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# App Engine Application
# ------------------------------------------------------------

resource "google_app_engine_application" "backend" {
  project     = var.project_id
  location_id = var.app_engine_location

  depends_on = [
    google_project_service.required_apis["appengine.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# D0 Raw Landing Module
# ------------------------------------------------------------

module "d0_raw_landing" {
  source = "./modules/d0-raw-landing"

  project_id      = var.project_id
  region          = var.region
  raw_bucket_name = var.raw_bucket_name

  ingestion_service_account_email = google_service_account.ingestion.email

  depends_on = [
    google_project_service.required_apis["storage.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# D1 Staged/Enforced Module
# ------------------------------------------------------------

module "d1_staged_enforced" {
  source = "./modules/d1-staged-enforced"

  project_id = var.project_id
  region     = var.region
  dataset_id = var.dataset_id
  table_id   = var.table_id

  analytics_service_account_email = google_service_account.analytics.email

  depends_on = [
    google_project_service.required_apis["bigquery.googleapis.com"]
  ]
}



# ------------------------------------------------------------
# Pub/Sub Schema
# ------------------------------------------------------------

resource "google_pubsub_schema" "student_onboarding" {
  name       = "student-onboarding-schema"
  project    = var.project_id
  type       = "AVRO"
  definition = file("${path.module}/pubsub-schema.avsc")

  depends_on = [
    google_project_service.required_apis["pubsub.googleapis.com"]
  ]
}

# ------------------------------------------------------------
# Pub/Sub Topic
# ------------------------------------------------------------

resource "google_pubsub_topic" "student_onboarding" {
  name    = "student-onboarding"
  project = var.project_id

  schema_settings {
    schema   = google_pubsub_schema.student_onboarding.id
    encoding = "JSON"
  }

  depends_on = [
    google_project_service.required_apis["pubsub.googleapis.com"],
    google_pubsub_schema.student_onboarding
  ]
}


# ------------------------------------------------------------
# Pub/Sub → BigQuery Subscription
# ------------------------------------------------------------

resource "google_pubsub_subscription" "student_onboarding_bigquery" {
  name    = "student-onboarding-bigquery"
  topic   = google_pubsub_topic.student_onboarding.id
  project = var.project_id

  bigquery_config {
    table               = "${var.project_id}:${var.dataset_id}.${var.table_id}"
    use_topic_schema    = true
    write_metadata      = false
    drop_unknown_fields = false
  }

  depends_on = [
    module.d1_staged_enforced,
    google_pubsub_topic.student_onboarding
  ]
}