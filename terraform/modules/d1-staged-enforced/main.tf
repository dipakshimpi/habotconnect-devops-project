/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: modules/d1-staged-enforced/main.tf
  Purpose: Creates the D1 Staged/Enforced BigQuery dataset, table,
           IAM access, and row-level security.

  Author: Dipak Shimpi
  Contact: shimpidipak81@gmail.com
*/

# ------------------------------------------------------------
# D1 Staged/Enforced — BigQuery Dataset
# ------------------------------------------------------------

resource "google_bigquery_dataset" "d1_staged_enforced" {
  dataset_id = var.dataset_id
  project    = var.project_id
  location   = var.region

  description = "Validated and enforced data layer for Habot Connect."
}

# ------------------------------------------------------------
# D1 Staged/Enforced — Student Onboarding Table
# ------------------------------------------------------------

resource "google_bigquery_table" "student_onboarding" {
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  project    = var.project_id
  table_id   = var.table_id

  schema = jsonencode([
    {
      name        = "student_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique identifier for the student."
    },
    {
      name        = "full_name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Student full name."
    },
    {
      name        = "email"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Student email address."
    },
    {
      name        = "owner_email"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Identity used to restrict row-level access."
    },
    {
      name        = "course"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Course or program selected by the student."
    },
    {
      name        = "status"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Current onboarding status."
    },
    {
      name        = "created_at"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Timestamp when the record was created."
    },
    {
      name        = "schema_version"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Version of the student onboarding event schema."
    }
  ])

  depends_on = [
    google_bigquery_dataset.d1_staged_enforced
  ]
}

# ------------------------------------------------------------
# D1 Analytics IAM
# ------------------------------------------------------------

resource "google_bigquery_dataset_iam_member" "analytics_viewer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.analytics_service_account_email}"
}

# ------------------------------------------------------------
# D1 Row-Level Security
# ------------------------------------------------------------

resource "google_bigquery_row_access_policy" "owner_access" {
  project          = var.project_id
  dataset_id       = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id         = google_bigquery_table.student_onboarding.table_id
  policy_id        = "owner_access"
  filter_predicate = "owner_email = SESSION_USER()"

  grantees = [
    "serviceAccount:${var.analytics_service_account_email}"
  ]
}

# ------------------------------------------------------------
# Pub/Sub → BigQuery Writer IAM
# ------------------------------------------------------------

resource "google_bigquery_dataset_iam_member" "pubsub_writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:service-326762783488@gcp-sa-pubsub.iam.gserviceaccount.com"
}