from django.db import models


class StudentOnboarding(models.Model):
    student_id = models.CharField(max_length=30, unique=True)
    full_name = models.CharField(max_length=100)
    email = models.EmailField(max_length=254)
    guardian_consent = models.BooleanField()
    learning_difficulty = models.CharField(max_length=50)
    age_band = models.CharField(max_length=20)
    emergency_contact = models.CharField(max_length=15)
    data_sharing_consent = models.BooleanField()

    def __str__(self):
        return self.student_id
