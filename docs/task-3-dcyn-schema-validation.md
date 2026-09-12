# Schema Mapping and DCYN Validation

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** GitHub — https://github.com/dipakshimpi

## Purpose

Task 3 addresses the database schema mismatch described in the project scenario.

The objective is to ensure that student onboarding data is validated using deterministic rules before it continues into the downstream data pipeline.

The validation flow is:

```text
Student Onboarding Form
        ↓
Django REST Framework API
        ↓
Model Serializer
        ↓
DCYN Validation
        ↓
Accept / Reject
        ↓
Pub/Sub
        ↓
BigQuery D1 Staged/Enforced
```

Invalid records are rejected before they can enter the downstream analytics flow.

## DCYN Logic

DCYN means **Deconstructed Clean Yes/No**.

The incoming onboarding payload is broken down into individual validation decisions. Each rule produces only a Yes or No result.

| Field / Rule | Decision |
|---|---|
| Student identifier is present and valid | Yes / No |
| Full name is valid | Yes / No |
| Email address is valid | Yes / No |
| Guardian consent satisfies the required rule | Yes / No |
| Learning difficulty is an allowed value | Yes / No |
| Age band is an allowed value | Yes / No |
| Emergency contact satisfies the required format | Yes / No |
| Data-sharing consent satisfies the required rule | Yes / No |

The final decision is deterministic:

```text
All required checks = Yes
        ↓
DCYN = Yes
        ↓
Accept
```

If any required check fails:

```text
Any required check = No
        ↓
DCYN = No
        ↓
Reject
```

This prevents validation from depending on individual human interpretation.

## Django REST Framework Validation

The Django REST Framework `ModelSerializer` provides the validation boundary for incoming onboarding data.

The serializer applies explicit rules for:

- Required fields
- Field length limits
- Allowed values
- Boolean values
- Email format
- Emergency contact format
- Whitespace normalization
- DCYN validation

The record is accepted only when serializer validation succeeds.

```text
Incoming JSON
     ↓
Serializer
     ↓
Field validation
     ↓
DCYN
     ↓
 ┌──────────┴──────────┐
 ↓                     ↓
YES                    NO
 ↓                     ↓
Accept                Reject
```

## Schema Consistency

The schema is treated as a contract between the application and downstream analytics.

The intended flow is:

```text
Django
   ↓
Validated Record
   ↓
Pub/Sub
   ↓
BigQuery D1
```

The application-side data structure must remain compatible with the BigQuery D1 schema.

This directly addresses the project incident where a database schema mismatch broke downstream analytics.

A schema change should therefore be treated as an intentional engineering change and validated before deployment rather than allowing an incompatible structure to reach the data pipeline.

## Pub/Sub and BigQuery Alignment

The validated onboarding record is designed to continue into the Pub/Sub to BigQuery pipeline without changing the meaning or structure of the fields.

The key principle is:

> Validate before publishing, and keep the published message compatible with the enforced BigQuery schema.

This prevents an application-side schema change from silently breaking downstream analytics.

For future schema changes, compatibility should be checked before deployment. A safe change process is:

```text
Developer changes schema
        ↓
Continuous Integration validation
        ↓
Application schema check
        ↓
BigQuery compatibility check
        ↓
PASS → Deploy
FAIL → Block
```

## Failure Handling

When validation fails, the Django API returns:

```text
HTTP 400 Bad Request
```

The frontend presents a simple user-facing message:

> Please check the entered information and try again.

Internal DCYN implementation details are not exposed to the end user.

When validation succeeds, the frontend displays:

> Onboarding submitted successfully.

## Poka-Yoke Relationship

DCYN is another mistake-proofing boundary in the application.

The GitHub Actions pipeline prevents bad code from progressing. The Django serializer and DCYN prevent bad data from progressing.

```text
BAD CODE
   ↓
GitHub Actions
   ↓
BLOCK
```

```text
BAD DATA
   ↓
Django Serializer
   ↓
DCYN
   ↓
BLOCK
```

This creates protection at both the development and application-data stages.

## Implementation Files

The Task 3 implementation is contained in:

```text
backend/
├── student_onboarding/
│   ├── dcyn.py
│   ├── models.py
│   ├── pubsub.py
│   ├── serializers.py
│   └── views.py
└── config/
    └── urls.py
```

The frontend submits the onboarding payload to the Django REST Framework endpoint:

```text
/api/student-onboarding/
```

## Result

Task 3 establishes a deterministic validation boundary for student onboarding data.

The implementation ensures that:

- Incoming data is validated before acceptance.
- Validation rules are explicit.
- DCYN produces deterministic Yes/No decisions.
- Invalid records are rejected.
- Application data remains aligned with the downstream analytics schema.
- Validation failures do not silently continue into the data pipeline.

This directly addresses the database schema mismatch and downstream analytics failure described in the hiring scenario.
