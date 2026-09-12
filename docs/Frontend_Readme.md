# Frontend — Student Onboarding

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** GitHub — `dipakshimpi/habotconnect-devops-project`

## Purpose

The frontend provides a simple student onboarding form and sends the submitted information to the Django REST Framework backend.

The frontend is intentionally lightweight and uses:

- HTML for the form structure
- CSS for presentation
- JavaScript for API communication
- Django REST Framework as the backend API

The frontend does not use React or Node.js. No `package.json`, npm dependencies, or React build process is required.

## Application Flow

```text
Student
   |
   v
Frontend Form
   |
   v
JavaScript
   |
   v
Django REST Framework API
   |
   v
Serializer Validation
   |
   v
DCYN Validation
   |
   +---- No ----> Request Rejected
   |
   +---- Yes ---> Pub/Sub
                    |
                    v
                 BigQuery D1
```

The frontend does not perform the authoritative validation itself. The Django backend remains the validation boundary.

## Files

```text
frontend/
├── index.html
├── style.css
└── script.js
```

- **`index.html`** — Contains the student onboarding form and the fields required by the backend.
- **`style.css`** — Provides the layout and styling for the onboarding form.
- **`script.js`** — Collects form values, converts consent selections into Boolean values, sends the JSON request to the backend, and displays the result message.

## Backend API

During local development, the frontend sends requests to:

```text
http://127.0.0.1:8000/api/student-onboarding/
```

The request uses:

```text
POST
Content-Type: application/json
```

The deployed Django backend is hosted on Google App Engine.

The production API endpoint is configured separately from the local development endpoint.

## Backend Processing

After the frontend submits the form, the backend performs the following steps:

```text
JSON Request
     |
     v
DRF ModelSerializer
     |
     v
Field Validation
     |
     v
DCYN Decision
     |
     +---- No ----> HTTP 400
     |
     +---- Yes
          |
          v
       Pub/Sub
          |
          v
       BigQuery D1
```

The backend is responsible for enforcing the data contract. The frontend is only responsible for collecting input and displaying the result.

## User-Facing Responses

The frontend keeps internal validation details hidden from the user.

| Scenario | Message |
|---|---|
| Successful submission | "Onboarding submitted successfully." |
| Validation failure | "Please check the entered information and try again." |
| Backend unavailable | "Unable to submit onboarding details. Please try again later." |
| Unexpected server error | "Something went wrong. Please try again." |

## Running the Frontend and Backend Together

The frontend and backend use separate development servers, so use two PowerShell terminals.

### Terminal 1 — Start Django Backend

From the project root:

```powershell
cd backend
python manage.py runserver
```

The backend should be available at `http://127.0.0.1:8000/`.

The onboarding API is `http://127.0.0.1:8000/api/student-onboarding/`.

### Terminal 2 — Start Frontend

Open a second PowerShell terminal:

```powershell
cd frontend
python -m http.server 5500
```

The frontend should be available at `http://127.0.0.1:5500/`.

Open the frontend in the browser using the address shown above.

## Why Two Servers Are Used

During local development, the frontend and Django backend run as separate services.

```text
Frontend Server
127.0.0.1:5500
       |
       | HTTP request
       v
Django Server
127.0.0.1:8000
       |
       v
Student Onboarding API
       |
       v
Validation + DCYN
```

The Django backend allows requests from the local frontend through the configured Cross-Origin Resource Sharing settings.

## Local Development Requirements

The backend requires the Python packages listed in `backend/requirements.txt`.

Install them from the backend directory with:

```powershell
cd backend
python -m pip install -r requirements.txt
```

Then start the backend and frontend using the commands above.

## Basic Test

1. Start the Django backend.
2. Start the frontend server.
3. Open the frontend in the browser.
4. Enter valid onboarding information.
5. Submit the form.
6. Confirm the success message appears.
7. Submit invalid information.
8. Confirm the validation message appears.
9. Stop the Django backend.
10. Submit the form again.
11. Confirm the backend-unavailable message appears.

A valid request is accepted only after backend serializer validation and the DCYN decision succeed.

## Validation Responsibility

The frontend provides basic user interaction, but it is not treated as a security or data-validation boundary.

The backend performs the authoritative checks for:

- Required values
- Field length limits
- Email format
- Allowed learning-difficulty values
- Allowed age-band values
- Emergency-contact format
- Guardian consent
- Data-sharing consent
- DCYN decision

This prevents invalid frontend input from being treated as trusted data.

## Deployment

The Django backend is deployed to Google App Engine using `backend/app.yaml`.

The App Engine service uses the dedicated `habot-backend` service account.

The deployed backend then publishes accepted onboarding events to the `student-onboarding` Google Cloud Pub/Sub topic.

## Design Summary

The frontend intentionally remains simple.

Its responsibility is:

```text
Collect Input
     |
     v
Send JSON
     |
     v
Display Result
```

The backend is responsible for validation and data processing:

```text
Receive JSON
     |
     v
Validate
     |
     v
DCYN
     |
     v
Publish Accepted Event
     |
     v
Pub/Sub
     |
     v
BigQuery D1
```

This separation keeps the frontend lightweight while ensuring that the authoritative validation and data contract are enforced by the backend.
