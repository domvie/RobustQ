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

"""defines Django database models"""


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/<user_id>/<filename>
    user = instance.user.username
    date = datetime.datetime.now().strftime('%d%m%y_%H%M%S')
    fname_noext = os.path.splitext(filename)[0][:10] # max 10 characters
    return '{0}_{1}/{2}_{3}/{4}'.format(instance.user.id, user, fname_noext, date, filename)


def givemetimezone():
    return timezone.localtime(timezone.now())


class Job(models.Model):
    """The basic Job model. """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    submit_date = models.DateTimeField(default=timezone.now)
    start_date = models.DateTimeField(null=True, blank=True)
    is_finished = models.BooleanField(default=False)
    finished_date = models.DateTimeField(blank=True, null=True)
    ip = models.GenericIPAddressField(null=True)
    compression = models.BooleanField(default=True)
    cardinality_defigueiredo = models.IntegerField(default=2, verbose_name='Cardinality MCS')
    cardinality_pof = models.IntegerField(default=10, verbose_name='Cardinality PoF')
    make_consistent = models.BooleanField(default=False)
    reactions = models.IntegerField(null=True)
    metabolites = models.IntegerField(null=True)
    genes = models.IntegerField(null=True)
    objective_expression = models.CharField(max_length=100, null=True)
    status = models.CharField(max_length=20, null=True, default='Queued')
    result = models.CharField(max_length=50, null=True, verbose_name='Result (PoF)')
    public_path = models.CharField(null=True, max_length=250)
    duration = models.CharField(null=True, max_length=15)
    task_id_job = models.CharField(max_length=50, null=True)
    model_name = models.CharField(max_length=50, null=True)
    result_table = models.CharField(max_length=250, null=True)
    sbml_file = ContentTypeRestrictedFileField(upload_to=user_directory_path, content_types=settings.ALLOWED_CONTENT_TYPES,
                                 validators=[FileExtensionValidator(allowed_extensions=settings.ALLOWED_EXTENSIONS,
                                                                    message='Wrong file type!'), sbml_validator],
                                 verbose_name='File', max_upload_size=settings.MAX_UPLOAD_SIZE)

    def get_absolute_url(self):
        return reverse('details', kwargs={'pk': self.pk})  # returns to e.g. jobs//details/1


class SubTask(models.Model):
    """connects Job - User - TaskResult models """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    task_result = models.OneToOneField(TaskResult, null=True, on_delete=models.DO_NOTHING)  # TODO maybe change cascade?
    task_id = models.CharField(max_length=50, null=False, unique=True)
    name = models.CharField(max_length=70, null=True)
    command_arguments = models.CharField(max_length=1000, null=True)
    logfile_path = models.CharField(null=True, max_length=250)
    duration = models.CharField(null=True, max_length=25)
