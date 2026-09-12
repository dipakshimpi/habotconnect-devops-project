import json

from django.conf import settings
from google.cloud import pubsub_v1

TOPIC_ID = "student-onboarding"
SCHEMA_VERSION = "1.0"


def publish_student_onboarding(data):
    publisher = pubsub_v1.PublisherClient()

    topic_path = publisher.topic_path(
        settings.GOOGLE_CLOUD_PROJECT,
        TOPIC_ID,
    )

    message = {
        "student_id": data["student_id"],
        "full_name": data["full_name"],
        "email": data["email"],
        "owner_email": data["email"],
        "course": "Habot Connect",
        "status": "accepted",
        "created_at": data["created_at"].isoformat(),
        "schema_version": SCHEMA_VERSION,
    }

    message_bytes = json.dumps(message).encode("utf-8")

    future = publisher.publish(
        topic_path,
        message_bytes,
    )

    return future.result()
