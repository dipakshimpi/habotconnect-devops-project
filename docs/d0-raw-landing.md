# D0 Raw Landing

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** +91 8956659030

## Purpose

D0 is the raw data landing layer of the staging data architecture.

It provides a controlled Cloud Storage location for raw incoming objects before they are validated and used by downstream processing.

The D0 bucket is provisioned and secured using Terraform.

```text
Raw Input
    |
    v
D0 - Cloud Storage
    |
    | validation / processing
    v
D1 - BigQuery
```

D0 and D1 are kept as separate layers so that raw input is not treated as trusted, validated data.

> **Implementation note:** The current Django API runtime path is Django → Pub/Sub → D1. The Django API does not currently write a raw copy into D0. D0 is provisioned as the raw landing infrastructure required by the staging architecture.

## Storage Configuration

The D0 bucket is configured with:

- Uniform bucket-level access
- Public access prevention
- Object versioning
- Google-managed encryption at rest
- Lifecycle rule to move objects to Nearline after 30 days

Terraform manages these settings so that the configuration is repeatable and consistent.

## IAM

A dedicated service account is created for ingestion:

```text
habot-ingestion@divine-bloom-441216-m7.iam.gserviceaccount.com
```

The service account receives:

- `roles/storage.objectCreator`

This allows the ingestion workload to create objects without granting unnecessary permissions such as deleting objects or managing the bucket.

The permission is conditionally scoped to objects within the D0 bucket.

## Poka-Yoke Controls

| Risk | Control |
|---|---|
| Public bucket access | Public access prevention |
| Inconsistent ACLs | Uniform bucket-level access |
| Accidental object loss | Object versioning |
| Uncontrolled storage growth | Lifecycle rule |
| Excess permissions | `roles/storage.objectCreator` |
| Manual infrastructure changes | Terraform |

The goal is to make the secure configuration the default rather than relying on manual checks.

## Terraform

The D0 bucket name and region are configurable through Terraform variables:

```hcl
raw_bucket_name = "habot-connect-devops-d0-raw-landing"
region          = "asia-south1"
```

The root Terraform configuration also creates the dedicated ingestion service account and passes its identity to the D0 module.

The D0 module manages:

- Cloud Storage Bucket
- Ingestion IAM Binding

## Validation

The Terraform configuration is checked using:

```bash
terraform fmt
terraform validate
terraform plan
```

The configuration has been validated against the current Terraform structure.

The final deployment state should be confirmed with the project's Terraform plan/apply results.

## Deployment Status

The D0 infrastructure is defined in Terraform and is part of the project's staging infrastructure.

The current GCP project has billing enabled, so the earlier limitation caused by inactive billing is no longer applicable.

The bucket is therefore treated as a deployable Terraform resource rather than an undeployed placeholder.

## Design Summary

D0 provides a controlled raw landing layer while D1 remains the validated and enforced data layer.

```text
Raw Input
    |
    v
D0 Cloud Storage
    |
    | validation / processing
    v
D1 BigQuery
    |
    v
Trusted Staged/Enforced Data
```

The D0 bucket is secured through Terraform using public access prevention, uniform bucket-level access, versioning, lifecycle management, and restricted ingestion permissions.
