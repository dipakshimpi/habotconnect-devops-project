# Poka-Yoke CI

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** +91 8956659030

## Purpose

This workflow provides a fail-closed validation boundary for changes made to the project.

The pipeline automatically checks Python code, CI configuration, Terraform configuration, frontend source files, and the repository for accidentally committed secrets.

If a required validation fails, the workflow stops with a failure instead of allowing the change to continue through the CI validation process.

This implements Poka-Yoke (mistake-proofing) by making important validation checks automatic rather than dependent on manual review.

## Pipeline

```text
Pull Request / Push
        |
        v
  Checkout Repository
        |
        v
   Python Quality
   /          \
Flake8      Black Check
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
 Frontend Files
        |
        v
    Gitleaks
        |
        v
      PASS
```

The workflow is implemented as a single validation job. A failed step causes the job to fail.

## Checks

### 1. Python Code Quality

The backend is checked using Flake8:

```bash
flake8 backend
```

Flake8 checks the Python source for common code-quality and formatting problems.

A failure causes the CI job to stop.

### 2. Python Formatting

Black is used in check-only mode:

```bash
black --check backend
```

The command verifies that the Python code follows the project's Black formatting standard.

The workflow does not automatically modify source files. If formatting is incorrect, the check fails and the developer must format the code before the change can pass CI.

### 3. YAML Lint

`yamllint` validates the GitHub Actions workflow:

```bash
yamllint .github/workflows/ci.yml
```

This helps prevent malformed or incorrectly formatted CI configuration from passing validation.

### 4. Terraform Formatting

Terraform formatting is checked using:

```bash
terraform fmt -check -recursive
```

The check fails when Terraform files are not formatted according to Terraform's standard formatting.

This keeps infrastructure code consistent without allowing CI to silently modify the submitted source.

### 5. Terraform Initialization

The workflow runs:

```bash
terraform init -backend=false
```

The backend is disabled because this CI job validates the Terraform configuration rather than managing Terraform state.

Terraform can therefore initialize its providers and modules without requiring access to the project's remote state.

### 6. Terraform Validation

The workflow runs:

```bash
terraform validate
```

This checks whether the Terraform configuration is syntactically valid and internally consistent.

It helps identify configuration errors before Terraform is used to manage infrastructure.

### 7. Frontend Source Verification

The project uses a lightweight HTML/CSS/JavaScript frontend.

The workflow verifies that the expected frontend source files exist:

- `frontend/index.html`
- `frontend/script.js`
- `frontend/style.css`

The project does not use React or a Node.js build process, so React-specific tooling such as ESLint is not required for the current frontend implementation.

### 8. Hardcoded Secret Detection

Gitleaks scans the repository for accidentally committed credentials and other secret patterns.

This directly addresses the project scenario where API credentials could accidentally be placed in application source code.

The workflow uses:

```yaml
- name: Scan repository for hardcoded secrets
  uses: gitleaks/gitleaks-action@v3
```

The repository must not contain real credentials.

If Gitleaks detects a secret pattern, the CI job fails.

## Fail-Closed Behavior

The workflow is intentionally sequential.

```text
Validation Check
       |
       v
    Pass?
    /   \
  Yes    No
   |      |
   v      v
Next    FAIL
Check   Job
```

A failed required step causes the workflow job to fail.

For example:

```text
Black Check
     |
     v
Formatting incorrect
     |
     v
   FAIL
     |
     v
Remaining validation
does not continue
```

This prevents known validation failures from being treated as successful CI results.

If the workflow is configured as a required status check in the repository's branch protection or ruleset, a failed workflow can also prevent the pull request from being merged.

## Poka-Yoke Controls

| Risk | Automated Control |
|---|---|
| Python code-quality problems | Flake8 |
| Incorrect Python formatting | `Black --check` |
| Invalid GitHub Actions YAML | yamllint |
| Unformatted Terraform | `terraform fmt -check` |
| Terraform initialization problems | `terraform init -backend=false` |
| Invalid Terraform configuration | `terraform validate` |
| Missing expected frontend files | File verification |
| Hardcoded credentials | Gitleaks |
| Accidental continuation after failure | Fail-closed sequential job |

The objective is to make the safe and validated path the default path.

## Least-Privilege CI Permissions

The workflow requests only read access to repository contents:

```yaml
permissions:
  contents: read
```

The workflow does not request repository write permissions.

This follows the principle of least privilege and limits the permissions available to the CI workflow.

## Terraform Security Boundary

The CI workflow validates Terraform configuration but does not automatically apply infrastructure changes.

The pipeline performs validation only:

```text
Terraform Code
      |
      v
 CI Validation
      |
      +---- Python Quality
      +---- YAML
      +---- Format
      +---- Init
      +---- Validate
      +---- Frontend Files
      +---- Secret Scan
      |
      v
 PASS / FAIL
```

Terraform deployment remains a separate controlled operation.

This prevents a normal source-code push from automatically modifying the cloud environment.

## Why These Checks Are Separate

Each check addresses a different failure mode.

```text
Flake8
   |
   +--> Python code quality

Black
   |
   +--> Python formatting

yamllint
   |
   +--> CI configuration correctness

terraform fmt
   |
   +--> Infrastructure code formatting

terraform init
   |
   +--> Provider and module initialization

terraform validate
   |
   +--> Terraform configuration correctness

Frontend file verification
   |
   +--> Expected frontend structure

Gitleaks
   |
   +--> Credential exposure
```

The tools are intentionally limited to the checks relevant to this project.

The pipeline does not add unrelated scanners simply to increase the number of tools.

## Workflow Trigger

The workflow runs on:

```yaml
on:
  push:
  pull_request:
```

This means validation runs when changes are pushed and when changes are proposed through a pull request.

## Current CI Workflow

The workflow is defined in `.github/workflows/ci.yml`.

The current implementation uses:

- GitHub Actions
- `actions/checkout@v6`
- `actions/setup-python@v6`
- Python 3.13
- Flake8
- Black
- yamllint
- `hashicorp/setup-terraform@v4`
- Terraform 1.14.8
- Gitleaks

No React or Node.js pipeline is included because the current frontend is plain HTML, CSS, and JavaScript.

## Expected Result

A valid project change should pass all required checks:

```text
Flake8                 PASS
Black                  PASS
YAML Lint              PASS
Terraform Format       PASS
Terraform Init         PASS
Terraform Validate     PASS
Frontend Files         PASS
Gitleaks               PASS
                        ----
                        PASS
```

A detected Python quality problem, formatting problem, YAML problem, Terraform validation problem, missing frontend file, or hardcoded secret causes the CI job to fail.

## Verification

The CI implementation should be tested with valid and intentionally invalid changes.

### Valid Case

A correctly formatted project with valid Terraform configuration and no committed credentials should pass all checks.

### Python Formatting Failure

An intentionally unformatted Python change should cause:

```text
black --check backend
        |
        v
       FAIL
```

The source should then be formatted and the check rerun.

### Terraform Formatting Failure

An intentionally unformatted Terraform change should cause:

```text
terraform fmt -check -recursive
        |
        v
       FAIL
```

The Terraform files should then be formatted before the change is considered valid.

### Secret Detection Failure

A temporary test containing a fake credential pattern can be used to verify that Gitleaks detects the problem.

No real credentials should ever be used for this test.

The temporary test file must be removed before committing the final project.

## CI Validation Philosophy

The purpose of the pipeline is not to provide the largest possible number of tools.

The purpose is to automatically prevent the specific mistakes that the project is designed to address:

```text
Code Change
    |
    v
Automated Checks
    |
    +---- Code Quality
    +---- Formatting
    +---- Configuration
    +---- Infrastructure Validation
    +---- Secret Detection
    |
    v
 PASS / FAIL
```

This reduces dependence on developers remembering every validation step manually.

## Outcome

The Poka-Yoke CI pipeline provides a repeatable validation boundary between source-code changes and infrastructure deployment.

It helps prevent:

- Python code-quality problems
- inconsistent Python formatting
- malformed CI configuration
- inconsistent Terraform formatting
- invalid Terraform configuration
- missing expected frontend files
- accidental credential exposure

The result is a fail-closed validation process that automatically catches common mistakes before they proceed further in the development workflow.
