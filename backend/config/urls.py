"""
Habot Connect FZCO — Junior Cloud & DevOps Engineer Hiring Project

File: backend/config/urls.py
Author: Dipak Shimpi
Contact: shimpidipak81@gmail.com
"""

from django.urls import path

from student_onboarding.views import StudentOnboardingView

urlpatterns = [
    path("api/student-onboarding/", StudentOnboardingView.as_view()),
]
