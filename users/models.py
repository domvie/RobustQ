from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


class UserHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateTimeField(null=False, default=timezone.now)
    ip = models.GenericIPAddressField(null=True)

    def __str__(self):
        return f'{self.user.username} History'

