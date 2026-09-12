"""
Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

File: backend/student_onboarding/dcyn.py
Author: Dipak Shimpi
Contact: shimpidipak81@gmail.com
"""


def check_dcyn(data):
    checks = {
        "guardian_consent": data.get("guardian_consent") is True,
        "data_sharing_consent": data.get("data_sharing_consent") is True,
        "emergency_contact": bool(data.get("emergency_contact")),
        "valid_age_band": data.get("age_band")
        in {
            "under_13",
            "13_to_17",
            "18_plus",
        },
        "valid_learning_difficulty": data.get("learning_difficulty")
        in {
            "none",
            "dyslexia",
            "dyscalculia",
            "adhd",
            "other",
        },
    }

    accepted = all(checks.values())

    checks_summary = {}
    for key, value in checks.items():
        checks_summary[key] = "Yes" if value else "No"

    return {
        "decision": "Yes" if accepted else "No",
        "checks": checks_summary,
    }
