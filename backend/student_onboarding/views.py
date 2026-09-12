from datetime import datetime, timezone

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .pubsub import publish_student_onboarding
from .serializers import StudentOnboardingSerializer


class StudentOnboardingView(APIView):
    def post(self, request):
        serializer = StudentOnboardingSerializer(data=request.data)

        if serializer.is_valid():
            event_data = {
                **serializer.validated_data,
                "created_at": datetime.now(timezone.utc),
            }

            try:
                publish_student_onboarding(event_data)
            except Exception:
                error_message = "Student onboarding could not be published."
                return Response(
                    {
                        "message": error_message,
                        "dcyn_decision": "Yes",
                    },
                    status=status.HTTP_503_SERVICE_UNAVAILABLE,
                )

            return Response(
                {
                    "message": "Student onboarding accepted.",
                    "student_id": event_data["student_id"],
                    "dcyn_decision": "Yes",
                },
                status=status.HTTP_201_CREATED,
            )

        return Response(
            {
                "message": "Student onboarding rejected.",
                "dcyn_decision": "No",
                "errors": serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
