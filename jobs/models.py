from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.core.validators import FileExtensionValidator
from .validators import sbml_validator
from django.urls import reverse
import datetime
from django_celery_results.models import TaskResult
from .formatChecker import ContentTypeRestrictedFileField
from django.conf import settings
import os


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/<user_id>/<filename>
    date = datetime.datetime.now().strftime('%d%m%y_%H%M%S')
    fname_noext = os.path.splitext(filename)[0][:10] # max 10 characters
    return '{0}/{1}_{2}/{3}'.format(instance.user.id, fname_noext, date, filename)


def givemetimezone():
    return timezone.localtime(timezone.now())


class Job(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    submit_date = models.DateTimeField(default=timezone.now)
    start_date = models.DateTimeField(null=True, blank=True)
    # expiry_date = models.DateTimeField(null=True, blank=True)
    is_finished = models.BooleanField(default=False)
    finished_date = models.DateTimeField(blank=True, null=True)
    ip = models.GenericIPAddressField(null=True)
    total_subtasks = models.IntegerField(null=True)
    status = models.CharField(max_length=20, null=True, default='Queued')
    result = models.CharField(max_length=50, null=True)
    sbml_file = ContentTypeRestrictedFileField(upload_to=user_directory_path, content_types=['text/xml', 'application/json',
                                                                                             'text/sbml'],
                                 validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml', 'json'],
                                                                    message='Wrong file type!'), sbml_validator],
                                 verbose_name='File', max_upload_size=settings.MAX_UPLOAD_SIZE)

    def get_absolute_url(self):
        return reverse('details', kwargs={'pk': self.pk})  # returns to e.g. jobs//details/1


class SubTask(models.Model):
    """connects Job - User - TaskResult models """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    task_result = models.OneToOneField(TaskResult, on_delete=models.CASCADE, null=True)
    task_id = models.CharField(max_length=50, null=False, unique=True)
    name = models.CharField(max_length=70, null=True)

