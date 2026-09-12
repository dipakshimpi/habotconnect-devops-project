# Frontend — Habot Connect Student Onboarding
 
**Project:** Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project  
**Author:** Dipak Shimpi  
**Contact:** GitHub — https://github.com/dipakshimpi  

## Overview

This directory contains the student onboarding user interface. It is a lightweight static application built using plain **HTML5**, **CSS3**, and **Vanilla JavaScript**.

No React, Vue, or Node.js runtime is required. Dependencies like `package.json`, `node_modules`, or Webpack/Vite are intentionally omitted to keep the frontend simple, reliable, and easily testable without a build pipeline.

## Files

- **`index.html`**: The semantic HTML onboarding form containing fields for student ID, full name, email, guardian consent, learning difficulties, age band, emergency contact, and data sharing consent.
- **`style.css`**: Responsive CSS styling for modern form layout and validation messaging.
- **`script.js`**: Client-side logic that collects form input, formats consent booleans, sends the JSON payload via `fetch()` to `http://127.0.0.1:8000/api/student-onboarding/`, and displays the response to the user.

## Running Locally

1. Start the Django backend (from `../backend`):
   ```bash
   python manage.py runserver
   ```
2. Serve the frontend with Python's built-in HTTP server:
   ```bash
   python -m http.server 5500
   ```
3. Open your browser and navigate to:
   ```text
   http://127.0.0.1:5500/
   ```

For detailed architectural and API documentation, see [`docs/Frontend_Readme.md`](../docs/Frontend_Readme.md).
