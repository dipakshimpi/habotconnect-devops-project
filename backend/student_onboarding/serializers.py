from rest_framework import serializers

from .dcyn import check_dcyn
from .models import StudentOnboarding


class StudentOnboardingSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentOnboarding
        fields = [
            "student_id",
            "full_name",
            "email",
            "guardian_consent",
            "learning_difficulty",
            "age_band",
            "emergency_contact",
            "data_sharing_consent",
        ]

    def validate_student_id(self, value):
        value = value.strip()

        if not value:
            raise serializers.ValidationError("Student ID cannot be empty.")

        return value

    def validate_full_name(self, value):
        value = value.strip()

        if not value:
            raise serializers.ValidationError("Full name cannot be empty.")

        return value

    def validate_learning_difficulty(self, value):
        allowed_values = {
            "none",
            "dyslexia",
            "dyscalculia",
            "adhd",
            "other",
        }

        value = value.strip().lower()

        if value not in allowed_values:
            raise serializers.ValidationError(
                "Learning difficulty is not a supported value."
            )

        return value

    def validate_age_band(self, value):
        allowed_values = {
            "under_13",
            "13_to_17",
            "18_plus",
        }

        value = value.strip().lower()

        if value not in allowed_values:
            raise serializers.ValidationError("Age band is not supported.")

        return value

    def validate_emergency_contact(self, value):
        value = value.strip()

        if not value.isdigit():
            raise serializers.ValidationError(
                "Emergency contact must contain digits only."
            )

        if len(value) < 10 or len(value) > 15:
            raise serializers.ValidationError(
                "Emergency contact must contain 10 to 15 digits."
            )

        return value

    def validate(self, attrs):
        result = check_dcyn(attrs)

        if result["decision"] == "No":
            raise serializers.ValidationError(
                {
                    "dcyn_decision": result["decision"],
                    "dcyn_checks": result["checks"],
                }
            )

        return attrs
