# D0 Raw Landing

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project  
**Author:** Dipak Shimpi  
**Contact:** +91 8956659030

## Purpose

D0 is the raw data landing layer of the pipeline.

Incoming files are stored here before validation and movement to the D1
Staged/Enforced layer in BigQuery.

```text
Source
  |
  v
D0 - Cloud Storage
  |
  | validation
  v
D1 - BigQuery

Keeping raw and validated data separate helps prevent bad input and schema
mismatches from reaching the trusted data layer.

Storage Configuration

The D0 bucket uses:

Uniform bucket-level access
Public access prevention
Object versioning
Google-managed encryption at rest
Lifecycle rule: move objects to Nearline after 30 days

Terraform manages these settings so the configuration is repeatable.

IAM

A dedicated service account is used for ingestion:

habot-ingestion@habot-connect-devops.iam.gserviceaccount.com

It receives:

roles/storage.objectCreator

This allows the ingestion workload to create objects without giving it
unnecessary permissions such as deleting objects or managing the bucket.

The permission is also conditionally scoped to objects in the D0 bucket.

Poka-Yoke Controls

The D0 setup prevents common configuration mistakes:

Risk	Control
Public bucket	Public access prevention
Inconsistent ACLs	Uniform bucket-level access
Accidental overwrite	Versioning
Uncontrolled storage growth	Lifecycle rule
Excess permissions	storage.objectCreator
Manual infrastructure changes	Terraform

The goal is to make the secure configuration the default rather than relying
on manual checks.

Terraform

The bucket name and region are configured through variables:

raw_bucket_name = "habot-connect-devops-d0-raw-landing"
region          = "asia-south1"

Terraform also manages the required APIs and service accounts used by the
architecture.

Validation

The configuration was checked using:

terraform fmt
terraform validate
terraform plan

The Terraform plan shows the expected D0 bucket and IAM resources.

Deployment Status

The D0 configuration has been validated with Terraform.

The bucket itself has not been created because the GCP project currently has
no active billing account.

Therefore, the project does not claim that the bucket is deployed.

The Terraform configuration is ready to apply when billing is available.

Design Summary

D0 keeps the raw data isolated from trusted data:

Raw data
   |
   v
D0 Cloud Storage
   |
   v
Validation
   |
   v
D1 BigQuery




