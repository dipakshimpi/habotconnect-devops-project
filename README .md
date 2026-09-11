# Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

**Author:** Dipak Shimpi
**Contact:** GitHub — https://github.com/dipakshimpi

## Overview

This project addresses the two failures described in the Habot Connect FZCO hiring scenario:

- Unencrypted API credentials were introduced into application code.
- A database schema mismatch broke downstream analytics.

The solution applies automated controls at three stages:

- GitHub Actions prevents insecure or non-compliant code from progressing.
- Django REST Framework and DCYN prevent invalid onboarding data from progressing into the downstream analytics pipeline.
- Terraform provisions the required Google Cloud infrastructure and access controls.

## Architecture

### Development Flow

```text
Developer
    ↓
GitHub Repository
    ↓
GitHub Actions
    ↓
Poka-Yoke Checks
    ├── YAML validation (yamllint)
    ├── Terraform formatting and validation (terraform fmt / terraform validate)
    ├── Hardcoded secret detection (Gitleaks)
    └── Infrastructure security scanning (Trivy)
    ↓
PASS → Continue
FAIL → Stop
```

### Data Flow

```text
Student
    ↓
Frontend
    ↓
Django REST Framework
    ↓
Model Serializer
    ↓
DCYN Validation
    ├── YES → Accept
    └── NO  → Reject
    ↓
Pub/Sub
    ↓
BigQuery D1 Staged/Enforced
    ↓
Analytics
```

Terraform provisions the infrastructure and identity boundaries supporting these flows.

## Task 1 — Secure Infrastructure Provisioning

Terraform provisions the Google Cloud environment required by the application and data pipeline.

### Infrastructure Components

- Google Cloud Storage D0 Raw Landing
- BigQuery D1 Staged/Enforced (student onboarding table)
- Google App Engine application
- Dedicated service accounts
- Least-privilege Identity and Access Management
- Conditional Identity and Access Management bindings
- BigQuery row-level security
- Storage versioning
- Storage lifecycle configuration

**Detailed documentation:** [`docs/d0-raw-landing.md`](docs/d0-raw-landing.md), [`docs/d1-staged-enforced.md`](docs/d1-staged-enforced.md)

## Task 2 — Poka-Yoke Fail-Closed Build Gate

The GitHub Actions workflow provides an automated mistake-proofing boundary for application and infrastructure changes.

The pipeline is intentionally fail-closed. A failed validation produces a non-zero result and prevents the workflow from progressing.

### Automated Checks

The workflow performs:

- YAML validation (yamllint)
- Terraform formatting validation (`terraform fmt -check`)
- Terraform initialization (`terraform init -backend=false`)
- Terraform validation (`terraform validate`)
- Hardcoded secret detection (Gitleaks)
- Infrastructure security scanning (Trivy)
- Python formatting and linting

### Fail-Closed Logic

```text
Code Change
    ↓
Automated Checks
    ├── PASS → Continue
    └── FAIL → STOP → Deployment blocked
```

The purpose is to prevent human review from being the final protection against mistakes.

**Detailed documentation:** [`docs/poka-yoke-ci.md`](docs/poka-yoke-ci.md)

## Task 3 — Schema Mapping and DCYN Validation

Student onboarding data passes through deterministic validation before entering the downstream analytics flow.

DCYN means Deconstructed Clean Yes/No. The validation rules are converted into explicit binary decisions.

```text
Incoming JSON
      ↓
Django REST Framework Serializer
      ↓
Field Validation
      ↓
DCYN
      ├── YES → Accept
      └── NO  → Reject
```

The application schema is treated as a contract with the downstream data pipeline.

```text
Django
   ↓
Validated Record
   ↓
Pub/Sub
   ↓
BigQuery D1
```

**Detailed documentation:** [`docs/task-3-dcyn-schema-validation.md`](docs/task-3-dcyn-schema-validation.md)

## Frontend

The project includes a lightweight student onboarding interface using HTML, CSS, and JavaScript. The frontend sends onboarding information to the Django REST Framework API.

### Run the Backend

From the backend directory:

```bash
python manage.py runserver
```

The backend runs at `http://127.0.0.1:8000/`.

### Run the Frontend

Open a second terminal and run from the frontend directory:

```bash
python -m http.server 5500
```

Open `http://127.0.0.1:5500/`.

The frontend submits data to `http://127.0.0.1:8000/api/student-onboarding/`.

**Detailed frontend documentation:** [`frontend/README.md`](frontend/README.md)

## Project Structure

```text
habotconnect-devops-project/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── backend/
│   ├── config/
│   ├── student_onboarding/
│   ├── manage.py
│   └── requirements.txt
│
├── frontend/
│   ├── README.md
│   ├── index.html
│   ├── script.js
│   └── style.css
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── modules/
│
├── docs/
│   ├── d0-raw-landing.md
│   ├── d1-staged-enforced.md
│   ├── poka-yoke-ci.md
│   └── task-3-dcyn-schema-validation.md
│
└── slides/
```

## Engineering Logic

The project applies mistake-proofing at three explicit boundaries, separating code safety, application validation, and downstream data enforcement:

| Boundary | Trigger | Control | Outcome |
|---|---|---|---|
| Development | Developer mistake (e.g. hardcoded secret, invalid Terraform) | GitHub Actions — yamllint, terraform fmt/validate, Gitleaks, Trivy | Blocked before merge |
| Application | Invalid onboarding data | Django REST Framework Serializer + DCYN | Blocked before acceptance |
| Data | Validated application data | Pub/Sub → BigQuery D1 | Flows through to Analytics |

## Key Engineering Principle

The system prevents mistakes instead of relying on people to remember to prevent them — at each of the three boundaries above: the development boundary (GitHub Actions), the application-data boundary (DRF + DCYN), and the infrastructure/identity boundary (Terraform).

## Submission Deliverables

The project includes:

- Completed Terraform infrastructure code
- GitHub Actions YAML workflow
- Django REST Framework Python implementation
- Frontend implementation
- Task documentation
- Architecture presentation
- Fail-Closed build demonstration

The architecture presentation is limited to 15 slides as required by the project instructions.

Before submission, the repository should be reviewed for:

- Full name and contact information
- No placeholders
- No unnecessary abbreviations
- Clear engineering logic
- Correct folder structure
- Fail-Closed demonstration
- Complete Terraform, YAML, and Python deliverables
