from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User


class Job(models.Model):
    start_date = models.DateTimeField(default=timezone.now)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    is_finished = models.BooleanField(default=False)
    time_finished = models.DateTimeField(default=timezone.now)
