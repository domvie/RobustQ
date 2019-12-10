from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.core.validators import FileExtensionValidator
from .validators import sbml_validator


class Job(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    submit_date = models.DateTimeField(default=timezone.now)
    start_date = models.DateTimeField(null=True, blank=True)
    is_finished = models.BooleanField(default=False)
    time_finished = models.DateTimeField(blank=True, null=True)
    ip = models.GenericIPAddressField(null=True)
    status = models.CharField(max_length=20, null=True, blank=True)
    sbml_file = models.FileField(name='',
                                 validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml'],
                                                                    message='Wrong file type!'),
                                             sbml_validator], verbose_name='File')
