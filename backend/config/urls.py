from django.urls import path

from student_onboarding.views import StudentOnboardingView

urlpatterns = [
    path("api/student-onboarding/", StudentOnboardingView.as_view()),
]
