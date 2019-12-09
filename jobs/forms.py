from django import forms
from django.contrib.auth.models import User
from .models import Job
import django_tables2 as tables
from datetime import datetime
import itertools
from django.core.validators import FileExtensionValidator


class JobSubmissionForm(forms.ModelForm):
    # sbml_file = forms.FileField(label='File to upload (SBML):')
                                # validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml'],
                                #                                    message='Wrong file type!')])

    class Meta:
        model = Job
        fields = ['sbml_file']


class CancelColumn(tables.Table):
    cancel = tables.Column()


class JobTable(CancelColumn, tables.Table):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.counter = itertools.count(start=1)

    def render_start_date(self, value):
        return datetime.strftime(value, "%b %d %Y, %H:%m")

    def render_id(self):
        return "%d" % next(self.counter)

    # def render_cancel(self):
    #     return format_html(f'<a href="#">X</a>')

    class Meta:
        model = Job
        fields = ['id', 'user', 'submit_date', 'start_date', 'SBML_file', 'status', 'is_finished', 'time_finished']

        row_attrs = {
            "data-id": lambda record: record.pk
        }
