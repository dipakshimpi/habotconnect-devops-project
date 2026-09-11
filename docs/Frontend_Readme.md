# Frontend — Student Onboarding

**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project
**Author:** Dipak Shimpi
**Contact:** GitHub — https://github.com/dipakshimpi

## Purpose

The frontend provides a simple student onboarding form and sends the submitted information to the Django REST Framework backend.

The frontend is intentionally lightweight and uses:

- HTML for the form structure
- CSS for presentation
- JavaScript for API communication
- Django REST Framework as the backend API

## Application Flow

```text
Student
   ↓
Frontend Form
   ↓
JavaScript
   ↓
Django REST Framework API
   ↓
Serializer Validation
   ↓
DCYN Validation
   ↓
Accepted or Rejected
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
- **`script.js`** — Collects the form values, converts the consent selections into Boolean values, sends the JSON request to the backend, and displays a simple result message.

## Backend API

The frontend sends requests to:

```text
http://127.0.0.1:8000/api/student-onboarding/
```

The request uses:

```text
POST
Content-Type: application/json
```

## User-Facing Responses

The frontend keeps internal validation logic hidden from the user.

| Scenario | Message |
|---|---|
| Successful submission | "Onboarding submitted successfully." |
| Validation failure | "Please check the entered information and try again." |
| Backend unavailable | "Unable to submit onboarding details. Please try again later." |
| Unexpected server error | "Something went wrong. Please try again." |

## Running the Frontend and Backend Together

The frontend and backend are separate development servers, so use two PowerShell terminals.

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

Open the frontend in the browser: `http://127.0.0.1:5500/`

## Why Two Servers Are Used

During local development, the Django backend and frontend are separate services.

```text
Frontend Server
127.0.0.1:5500
       │
       │ HTTP request
       ↓
Django Server
127.0.0.1:8000
       │
       ↓
Student Onboarding API
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
3. Open `http://127.0.0.1:5500/`.
4. Enter valid onboarding information.
5. Submit the form.
6. Confirm the success message appears.
7. Submit invalid information.
8. Confirm the validation message appears.
9. Stop the Django backend and submit again.
10. Confirm the backend-unavailable message appears.

This verifies the complete local frontend-to-backend interaction.
