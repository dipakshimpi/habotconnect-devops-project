# D1 Staged / Enforced

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** +91 8956659030

## Purpose

D1 is the staged and enforced data layer of the Habot Connect data pipeline.

It is implemented using BigQuery and provides an explicit schema and controlled access boundary for validated student onboarding data.

The current application flow is:

```text
Student Onboarding Request
        |
        v
Django REST API
        |
        | validation + DCYN
        v
Google Cloud Pub/Sub
        |
        | topic schema
        v
BigQuery Subscription
        |
        v
D1 - Staged / Enforced
```

D0 is maintained as a separate raw landing layer. The current Django API does not directly write the onboarding request to D0.

## BigQuery Configuration

The D1 dataset is:

- **Dataset:** `d1_staged_enforced`
- **Location:** `asia-south1`

The validated table is:

- **Table:** `student_onboarding`

Terraform manages the dataset, table, IAM configuration, and row-level access policy.

## Table Schema

| Field | Type | Mode | Purpose |
|---|---|---|---|
| `student_id` | STRING | REQUIRED | Unique student identifier |
| `full_name` | STRING | REQUIRED | Student name |
| `email` | STRING | REQUIRED | Student email address |
| `owner_email` | STRING | REQUIRED | Owner identity used by the row-level access policy |
| `course` | STRING | REQUIRED | Course associated with the student |
| `status` | STRING | REQUIRED | Current onboarding status |
| `created_at` | TIMESTAMP | REQUIRED | Record creation timestamp |
| `schema_version` | STRING | NULLABLE | Version of the onboarding event schema |

The table uses an explicit schema rather than accepting arbitrary columns.

Required fields must be present for a valid D1 record. `schema_version` is intentionally nullable to support schema compatibility and controlled evolution.

## Data Flow

The application validates the onboarding request before publishing it to Pub/Sub.

```text
Incoming JSON
      |
      v
DRF ModelSerializer
      |
      v
DCYN Decision
      |
      | Yes
      v
Pub/Sub Topic
      |
      v
BigQuery Subscription
      |
      v
D1 student_onboarding
```

This creates a validation boundary before the data reaches the D1 table.

## Pub/Sub Schema Contract

The Pub/Sub topic uses an AVRO schema named `student-onboarding-schema`.

The event contains:

| Field | Pub/Sub Type | BigQuery Type |
|---|---|---|
| `student_id` | string | STRING |
| `full_name` | string | STRING |
| `email` | string | STRING |
| `owner_email` | string | STRING |
| `course` | string | STRING |
| `status` | string | STRING |
| `created_at` | timestamp-micros | TIMESTAMP |
| `schema_version` | nullable string | STRING |

The `created_at` field uses an AVRO `timestamp-micros` logical type and is stored as a BigQuery `TIMESTAMP`.

This keeps the timestamp contract explicit instead of relying on implicit string conversion.

## Schema Versioning

Each onboarding event includes `schema_version = "1.0"`.

The schema version provides an explicit contract between the Django producer, Pub/Sub, and BigQuery.

If the event structure changes in the future, the schema version can be updated and compatibility can be checked before changing the downstream table contract.

The Pub/Sub → BigQuery subscription uses the topic schema (`use_topic_schema = true`).

Unknown fields are not silently discarded (`drop_unknown_fields = false`).

This helps make schema mismatches visible instead of silently losing data.

## IAM

A dedicated analytics service account is used for D1 data access:

```text
habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com
```

It receives:

- `roles/bigquery.dataViewer`

This provides read access to BigQuery data without granting the analytics identity administrative control over the dataset or infrastructure.

D0 ingestion and D1 analytics use separate service accounts.

## Row-Level Security

D1 includes a BigQuery row-level access policy:

- **Policy:** `owner_access`

The policy uses:

```sql
owner_email = SESSION_USER()
```

The purpose of this policy is to restrict rows according to the identity of the current BigQuery session.

The policy is associated with the analytics service account `habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com`.

The `owner_email` field provides the ownership attribute used by the policy.

The RLS resource is managed through Terraform.

### RLS Validation Status

The RLS policy is provisioned as part of the D1 infrastructure.

A live identity-based RLS query has not been used as the basis for claiming a successful row-filtering demonstration yet.

Therefore the project documentation does not claim a completed live RLS behavior test.

## Poka-Yoke Controls

| Risk | Control |
|---|---|
| Missing required fields | Required BigQuery schema fields |
| Unexpected data structure | Explicit table schema |
| Schema mismatch | Pub/Sub topic schema |
| Silent unknown fields | `drop_unknown_fields = false` |
| Uncontrolled analytics permissions | Dedicated analytics service account |
| Unnecessary write access | `roles/bigquery.dataViewer` |
| Cross-row data exposure | BigQuery row-level access policy |
| Manual infrastructure configuration | Terraform |

The objective is to enforce the expected data contract and access rules through configuration rather than relying only on manual checks.

## Least Privilege

The analytics service account receives `roles/bigquery.dataViewer` rather than a broader administrative role.

The analytics identity is intended to read D1 data, not manage BigQuery infrastructure.

The ingestion and analytics service accounts are separate so that their responsibilities remain isolated.

## Pub/Sub → BigQuery Subscription

Terraform creates the subscription `student-onboarding-bigquery`.

It connects:

```text
student-onboarding
        |
        v
d1_staged_enforced.student_onboarding
```

The subscription uses the Pub/Sub topic schema (`use_topic_schema = true`) and does not silently remove fields that are not present in the destination schema (`drop_unknown_fields = false`).

The current deployed subscription is configured with an active BigQuery sink.

## Terraform Resources

The following D1 resources are managed by Terraform:

- `google_bigquery_dataset`
- `google_bigquery_table`
- `google_bigquery_dataset_iam_member`
- `google_bigquery_row_access_policy`

The resource definitions are located in `terraform/modules/d1-staged-enforced/`.

The Pub/Sub schema, topic, and BigQuery subscription are managed from the root Terraform configuration.

## Current D1 Resources

| Item | Value |
|---|---|
| Project | `divine-bloom-441216-m7` |
| Dataset | `d1_staged_enforced` |
| Table | `student_onboarding` |
| Analytics Service Account | `habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com` |
| IAM Role | `roles/bigquery.dataViewer` |
| Row-Level Security Policy | `owner_access` |
| Pub/Sub Topic | `student-onboarding` |
| BigQuery Subscription | `student-onboarding-bigquery` |

## Validation

The infrastructure configuration is checked using:

```bash
terraform fmt
terraform validate
terraform plan
```

The Django backend is checked using:

```bash
python -m black --check backend
python -m flake8 backend
python backend/manage.py check
```

The Pub/Sub and BigQuery resources are also verified through their deployed GCP configuration.

## Expected Data Contract

A successfully accepted onboarding event follows this structure:

```json
{
  "student_id": "STU1001",
  "full_name": "Aarav Sharma",
  "email": "aarav@example.com",
  "owner_email": "aarav@example.com",
  "course": "Habot Connect",
  "status": "accepted",
  "created_at": "timestamp",
  "schema_version": "1.0"
}
```

The API does not publish the event until the DRF serializer and DCYN validation succeed.

## Outcome

D1 provides a controlled staged data layer for downstream consumers.

The implementation combines:

- explicit BigQuery schema
- required fields
- Pub/Sub schema enforcement
- schema versioning
- dedicated service accounts
- least-privilege IAM
- row-level access control
- Terraform-managed infrastructure

This creates an explicit boundary between validated onboarding events and downstream BigQuery consumers.
