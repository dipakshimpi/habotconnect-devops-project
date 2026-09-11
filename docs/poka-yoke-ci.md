Poka-Yoke CI

Project: Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
Author: Dipak Shimpi
Contact: +91 8956659030

Purpose

This workflow validates infrastructure changes before they are accepted.

The pipeline follows a fail-closed approach: if a required validation fails,
the workflow stops instead of allowing the change to continue.

This provides automated mistake-proofing (Poka-Yoke) for infrastructure and
CI configuration.

Pipeline

Pull Request / Push
        |
        v
   YAML Lint
        |
        v
 Terraform fmt
        |
        v
 Terraform init
        |
        v
 Terraform validate
        |
        v
    Gitleaks
        |
        v
     Trivy
        |
        v
      PASS

Checks

1. YAML Lint

yamllint checks the GitHub Actions workflow for YAML syntax and formatting
problems.

This prevents a malformed CI workflow from being accepted.

Command:

yamllint .github/workflows/ci.yml

2. Terraform Formatting

Terraform formatting is checked using:

terraform fmt -check -recursive

The check fails when Terraform files are not formatted according to
Terraform's standard formatting.

This keeps infrastructure code consistent and prevents formatting mistakes
from passing unnoticed.

3. Terraform Initialization

The workflow runs:

terraform init -backend=false

The backend is disabled because this CI job is validating the Terraform
configuration rather than managing Terraform state.

This allows Terraform to initialize its providers and modules without
requiring access to a remote state backend.

4. Terraform Validation

The workflow runs:

terraform validate

This checks whether the Terraform configuration is syntactically valid
and internally consistent.

It helps detect configuration errors before infrastructure changes are
applied.

5. Hardcoded Secret Detection

Gitleaks scans the repository for accidentally committed credentials and
other secret patterns.

This directly addresses the project's scenario where API credentials could
be accidentally left in source code.

The repository does not contain real credentials.

The CI job fails if Gitleaks detects a secret.

6. Infrastructure Security Scan

Trivy scans the Terraform configuration for infrastructure security
misconfigurations.

The scan is limited to HIGH and CRITICAL findings so that the pipeline
focuses on issues that require immediate attention.

Configuration:

scan-type: config
scan-ref: terraform
severity: HIGH,CRITICAL
exit-code: 1

A HIGH or CRITICAL finding causes the CI job to fail.

Fail-Closed Behavior

The workflow is intentionally sequential.

Validation Check
       |
       v
    Pass?
    /   \
  Yes    No
   |      |
   v      v
 Next    FAIL
 Check   Pipeline

If a required step fails, the job stops and the change is not considered
valid.

This means developers do not need to remember every validation manually.
The pipeline automatically enforces the required checks.

Poka-Yoke Controls

Risk

Automated Control

Invalid GitHub Actions YAML

yamllint

Unformatted Terraform

terraform fmt -check

Terraform initialization problems

terraform init -backend=false

Invalid Terraform configuration

terraform validate

Hardcoded credentials

Gitleaks

Infrastructure security misconfiguration

Trivy

Accidental continuation after failure

Fail-closed sequential job

The objective is to make the safe path the default path.

Least-Privilege CI Permissions

The workflow requests only read access to repository contents:

permissions:
  contents: read

The CI workflow does not request write permissions to the repository.

This follows the principle of least privilege and limits what the workflow
can do if the workflow itself is compromised.

Terraform Security Boundary

The CI workflow validates Terraform configuration but does not automatically
apply infrastructure changes.

The pipeline performs validation only:

Terraform Code
      |
      v
CI Validation
      |
      +---- YAML
      +---- Format
      +---- Init
      +---- Validate
      +---- Secret Scan
      +---- Security Scan
      |
      v
PASS / FAIL

Terraform deployment remains a separate controlled operation.

This prevents a normal code push from automatically modifying the cloud
environment.

Why These Checks Are Separate

Each tool addresses a different failure mode.

yamllint
   |
   +--> CI configuration correctness

terraform fmt
   |
   +--> Infrastructure code consistency

terraform init
   |
   +--> Provider/module initialization

terraform validate
   |
   +--> Terraform configuration correctness

Gitleaks
   |
   +--> Credential exposure

Trivy
   |
   +--> Infrastructure security

The tools are intentionally limited to the checks required for this project.
Additional scanners are not added just to increase the number of tools.

Workflow Trigger

The workflow runs on:

on:
  push:
  pull_request:

This means validation happens both when changes are pushed and when changes
are proposed through a pull request.

Current CI Workflow

The workflow is defined in:

.github/workflows/ci.yml

The current implementation uses:

GitHub Actions

actions/checkout@v6

hashicorp/setup-terraform@v4

Terraform 1.14.8

yamllint

Gitleaks

Trivy

Expected Result

A valid infrastructure change should pass all checks:

YAML Lint              PASS
Terraform Format       PASS
Terraform Init         PASS
Terraform Validate     PASS
Gitleaks               PASS
Trivy                  PASS
                       ----
                       PASS

A detected formatting problem, hardcoded secret, or configured HIGH/CRITICAL
security finding causes the workflow to fail.

Verification

The CI implementation should be tested with both valid and intentionally
invalid examples.

Valid case

A correctly formatted and secure Terraform configuration should pass all
checks.

Formatting failure

An intentionally malformed Terraform formatting change should cause:

terraform fmt -check -recursive
        |
        v
       FAIL

The formatting should then be restored.

Secret detection failure

A temporary test containing a fake credential pattern can be used to verify
that Gitleaks detects the problem.

No real credentials should ever be used for this test.

The temporary test file must be removed before committing the final project.

Outcome

The Poka-Yoke CI pipeline provides an automated validation boundary between
source-code changes and infrastructure deployment.

It helps prevent:

malformed CI configuration

inconsistent Terraform formatting

invalid Terraform configuration

accidental credential exposure

high-severity infrastructure security misconfigurations

The result is a repeatable, fail-closed validation process that reduces
dependence on manual checks.