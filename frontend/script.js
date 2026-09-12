/*
  Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

  File: frontend/script.js
  Author: Dipak Shimpi
  Contact: shimpidipak81@gmail.com
*/

const form = document.getElementById("onboarding-form");
const result = document.getElementById("result");

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    result.className = "result";
    result.textContent = "Submitting...";

    const data = {
        student_id: document.getElementById("student_id").value,
        full_name: document.getElementById("full_name").value,
        email: document.getElementById("email").value,
        guardian_consent:
            document.getElementById("guardian_consent").value === "true",
        learning_difficulty:
            document.getElementById("learning_difficulty").value,
        age_band: document.getElementById("age_band").value,
        emergency_contact:
            document.getElementById("emergency_contact").value,
        data_sharing_consent:
            document.getElementById("data_sharing_consent").value === "true",
    };

    try {
        const response = await fetch(
            "http://127.0.0.1:8000/api/student-onboarding/",
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(data),
            }
        );

        if (response.ok) {
            result.className = "result success";
            result.textContent = "Onboarding submitted successfully.";
            form.reset();
            return;
        }

        if (response.status === 400) {
            result.className = "result error";
            result.textContent =
                "Please check the entered information and try again.";
            return;
        }

        result.className = "result error";
        result.textContent =
            "Something went wrong. Please try again.";
    } catch (error) {
        result.className = "result error";
        result.textContent =
            "Unable to submit onboarding details. Please try again later.";
    }
});