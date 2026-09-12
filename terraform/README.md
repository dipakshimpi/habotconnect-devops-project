# Terraform Infrastructure — Habot Connect

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project  
**Author:** Dipak Shimpi  
**Contact:** GitHub — https://github.com/dipakshimpi  

## Overview

This directory contains the Infrastructure-as-Code (IaC) configuration for the Habot Connect hiring project using HashiCorp Terraform.

The infrastructure provisions and enforces Google Cloud resources required by the application and analytics pipeline according to the principle of least privilege.

## Architecture & Resources

```text
               ┌───────────────────────┐
               │    Google Storage     │
               │    (D0 Raw Landing)   │
               └───────────────────────┘

┌─────────────────┐       ┌─────────────────┐       ┌────────────────────────┐
│  Django Backend │ ----> │  Pub/Sub Topic  │ ----> │  BigQuery Table (D1)   │
│  (App Engine)   │       │ student-onboard │       │ student_onboarding     │
└─────────────────┘       └────────┬────────┘       └────────────────────────┘
                                   │                             ▲
                                   ▼                             │
                          AVRO Schema Contract          Row-Level Security (RLS)
                        (student-onboarding-schema)    (owner_email = SESSION_USER())
```

### Components Managed:
1. **Google Cloud APIs**: Enables `storage`, `bigquery`, `iam`, `appengine`, and `pubsub`.
2. **Identity & Access Management (IAM)**:
   - `habot-ingestion`: Storage object creator scoped to the D0 bucket.
   - `habot-analytics`: Data viewer and query runner for BigQuery D1.
   - `habot-backend`: Service account for Django on App Engine.
   - Pub/Sub Service Agent: Granted `roles/bigquery.dataEditor` to stream events from Pub/Sub to BigQuery.
3. **Storage (D0 Raw Landing)**:
   - Uniform bucket-level access and public access prevention.
   - Object versioning and 30-day lifecycle rule to Nearline storage.
4. **Data Warehouse (D1 Staged/Enforced)**:
   - BigQuery dataset `d1_staged_enforced`.
   - BigQuery table `student_onboarding` with strict schema validation.
   - Row-Level Access Policy (`owner_access`) restricting row access to `owner_email = SESSION_USER()`.
5. **Streaming Ingestion (Pub/Sub ➔ BigQuery)**:
   - AVRO Schema `student-onboarding-schema` defined in `pubsub-schema.avsc`.
   - Pub/Sub Topic `student-onboarding` enforcing JSON-encoded AVRO messages.
   - Direct BigQuery Subscription `student-onboarding-bigquery` with `useTopicSchema = true`.

## Directory Structure

```text
terraform/
├── main.tf                 # Root orchestration and shared resources
├── variables.tf            # Input variable declarations
├── outputs.tf              # Exported resource IDs, emails, and endpoints
├── versions.tf             # Terraform and Google provider constraints
├── pubsub-schema.avsc      # AVRO schema for the student onboarding event
└── modules/
    ├── d0-raw-landing/     # Google Cloud Storage raw landing bucket
    └── d1-staged-enforced/ # BigQuery dataset, table, IAM, and RLS policy
```

## Validation & Usage

All Terraform code is validated automatically in CI through GitHub Actions:

```bash
# Check standard formatting
terraform fmt -check -recursive

# Initialize without remote backend (for validation)
terraform init -backend=false

# Validate syntax and configuration integrity
terraform validate
```

For detailed layer documentation:
- [`docs/d0-raw-landing.md`](../docs/d0-raw-landing.md)
- [`docs/d1-staged-enforced.md`](../docs/d1-staged-enforced.md)
