from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.core.validators import FileExtensionValidator
from .validators import sbml_validator
from django.urls import reverse
import datetime
from django_celery_results.models import TaskResult


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/<user_id>/<filename>
    date = datetime.datetime.now().strftime('%d%m%y_%H%M%S')
    return '{0}/{1}/{2}'.format(instance.user.id, date, filename)


def givemetimezone():
    return timezone.localtime(timezone.now())


class Job(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    submit_date = models.DateTimeField(default=timezone.now)
    start_date = models.DateTimeField(null=True, blank=True)
    is_finished = models.BooleanField(default=False)
    finished_date = models.DateTimeField(blank=True, null=True)
    ip = models.GenericIPAddressField(null=True)
    status = models.CharField(max_length=20, null=True, default='Queued')
    sbml_file = models.FileField(upload_to=user_directory_path,
                                 validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml'],
                                                                    message='Wrong file type!'), sbml_validator],
                                 verbose_name='File')

    def get_absolute_url(self):
        return reverse('details', kwargs={'pk': self.pk})  # returns to e.g. jobs//details/1


class SubTask(models.Model):
    """connects Job - User - TaskResult models """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    task_result = models.OneToOneField(TaskResult, on_delete=models.CASCADE, null=True)
    task_id = models.CharField(max_length=50, null=False, unique=True)
    # status_task = models.CharField(max_length=20, default='Not started')
    name = models.CharField(max_length=20, null=True)

