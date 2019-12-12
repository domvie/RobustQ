from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.core.validators import FileExtensionValidator
from .validators import sbml_validator
from django.urls import reverse


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/<user_id>/<filename>
    return '{0}/{1}'.format(instance.user.id, filename)


def givemetimezone():
    return timezone.localtime(timezone.now())


class Job(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    submit_date = models.DateTimeField(default=givemetimezone)
    start_date = models.DateTimeField(null=True, blank=True)
    is_finished = models.BooleanField(default=False)
    time_finished = models.DateTimeField(blank=True, null=True)
    ip = models.GenericIPAddressField(null=True)
    status = models.CharField(max_length=20, null=True, blank=True)
    sbml_file = models.FileField(name='', upload_to=user_directory_path,
                                 validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml'],
                                                                    message='Wrong file type!'),
                                             sbml_validator], verbose_name='File')

    def get_absolute_url(self):
        return reverse('details', kwargs={'pk': self.pk}) # returns to e.g. jobs//details/1
