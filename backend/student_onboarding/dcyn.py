def check_dcyn(data):
    checks = {
        "guardian_consent": data.get("guardian_consent") is True,
        "data_sharing_consent": data.get("data_sharing_consent") is True,
        "emergency_contact": bool(data.get("emergency_contact")),
        "valid_age_band": data.get("age_band") in {
            "under_13",
            "13_to_17",
            "18_plus",
        },
        "valid_learning_difficulty": data.get("learning_difficulty") in {
            "none",
            "dyslexia",
            "dyscalculia",
            "adhd",
            "other",
        },
    }

    accepted = all(checks.values())

    return {
        "decision": "Yes" if accepted else "No",
        "checks": {
            key: "Yes" if value else "No"
            for key, value in checks.items()
        },
    }
