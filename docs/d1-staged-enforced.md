# D1 Staged / Enforced

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** +91 8956659030

## Purpose

D1 is the staged and enforced data layer of the pipeline.

Data that reaches D1 is expected to follow the defined schema and access controls. D1 is implemented using BigQuery.

```text
D0 - Raw Landing
        |
        | validation
        v
D1 - Staged / Enforced
        |
        v
BigQuery
```

Separating the raw landing layer from the trusted staged layer helps prevent unvalidated input and schema mismatches from reaching downstream consumers.

## BigQuery Configuration

The D1 dataset is:

- **Dataset:** `d1_staged_enforced`
- **Location:** `asia-south1`

The validated table is:

- **Table:** `student_onboarding`

Terraform manages the dataset and table so the configuration is repeatable.

## Table Schema

| Field | Type | Mode | Purpose |
|---|---|---|---|
| `student_id` | STRING | REQUIRED | Unique student identifier |
| `full_name` | STRING | REQUIRED | Student name |
| `email` | STRING | REQUIRED | Student email address |
| `owner_email` | STRING | REQUIRED | Owner identifier used by the row-level access policy |
| `course` | STRING | REQUIRED | Course associated with the student |
| `status` | STRING | REQUIRED | Current onboarding status |
| `created_at` | TIMESTAMP | REQUIRED | Record creation timestamp |

All fields are required. This provides an explicit contract for the D1 data structure instead of accepting arbitrary columns or missing required values.

## Data Validation Boundary

```text
Incoming Data
      |
      v
D0 Raw Landing
      |
      | validation / schema enforcement
      v
D1 Staged / Enforced
      |
      v
Downstream Consumers
```

D0 preserves the incoming raw data. D1 represents the enforced schema that downstream workloads can rely on.

## IAM

A dedicated analytics service account is used for access to the D1 data:

```text
habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com
```

It receives:

- `roles/bigquery.dataViewer`

This role provides read access to BigQuery data without granting permissions to modify the infrastructure or table definition.

## Row-Level Security

D1 includes a BigQuery row-level access policy:

- **Policy:** `owner_access`

The policy uses:

```sql
owner_email = SESSION_USER()
```

This means the rows visible to the grantee are filtered according to the identity of the current BigQuery session.

The policy is granted to:

```text
serviceAccount:habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com
```

This provides an additional data-access boundary beyond the dataset-level IAM permission.

## Poka-Yoke Controls

| Risk | Control |
|---|---|
| Missing required fields | Required BigQuery schema fields |
| Unexpected data structure | Explicit table schema |
| Uncontrolled analytics permissions | Dedicated analytics service account |
| Unnecessary write access | `roles/bigquery.dataViewer` |
| Cross-row data exposure | Row-level access policy |
| Manual infrastructure configuration | Terraform |

The objective is to enforce the expected data contract and access rules through configuration rather than relying only on manual checks.

## Least Privilege

The analytics service account is given `roles/bigquery.dataViewer` rather than a broader administrative role.

The service account is intended for reading D1 data, not for managing BigQuery infrastructure.

D0 ingestion and D1 analytics use separate service accounts so their responsibilities remain isolated.

## Terraform Resources

The following D1 resources are managed by Terraform:

- `google_bigquery_dataset`
- `google_bigquery_table`
- `google_bigquery_dataset_iam_member`
- `google_bigquery_row_access_policy`

The resource definitions are located in `terraform/modules/d1-staged-enforced/`.

## Current D1 Resources

| Item | Value |
|---|---|
| Project | `divine-bloom-441216-m7` |
| Dataset | `d1_staged_enforced` |
| Table | `student_onboarding` |
| Analytics Service Account | `habot-analytics@divine-bloom-441216-m7.iam.gserviceaccount.com` |
| IAM Role | `roles/bigquery.dataViewer` |
| Row-Level Security Policy | `owner_access` |

## Implementation Note

The current row-level security policy uses `owner_email` as the ownership attribute (`owner_email = SESSION_USER()`).

This is an implementation assumption because the project brief requires row-level security but does not define a specific ownership field. For this proof of concept, `owner_email` provides a concrete field for demonstrating the row-level access mechanism.

During final validation, the behavior of the policy should be demonstrated with appropriate test records and identities.

## Expected Result

| Check | Result |
|---|---|
| Explicit schema | PASS |
| Required fields | PASS |
| Dedicated analytics IAM | PASS |
| Read-only data access | PASS |
| Row-level security | PASS |
| Terraform management | PASS |

The final validation will verify the deployed BigQuery resources directly.

## Outcome

D1 provides a controlled data layer between raw ingestion and downstream consumers.

The combination of:

- explicit BigQuery schema
- required fields
- dedicated service accounts
- least-privilege IAM
- row-level security
- Terraform-managed configuration

creates an enforced boundary for trusted staged data.
