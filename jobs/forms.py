from django import forms
from .models import Job
import django_tables2 as tables
from datetime import datetime
import itertools


class JobSubmissionForm(forms.ModelForm):

    class Meta:
        model = Job
        fields = ['sbml_file']

    def __init__(self, *args, **kwargs):
        super(JobSubmissionForm, self).__init__(*args, **kwargs)
        self.fields['sbml_file'].widget.attrs.update({'class': 'custom-file-input',
                                                      'aria-describedby': 'id_sbml_file_Addon01',
                                                      'data-toggle': 'popover',
                                                      'title': 'Error!',
                                                      'data-content': ''})


class CancelColumn(tables.Table):
    cancel = tables.Column()


class JobTable(CancelColumn, tables.Table):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.counter = itertools.count(start=1)

    def render_start_date(self, value):
        try:
            return datetime.strftime(value, "%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    def render_submit_date(self, value):
        try:
            return datetime.strftime(value, "%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    def render_time_finished(self, value):
        try:
            return datetime.strftime(value, "%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    def render_id(self):
        return "%d" % next(self.counter)

    class Meta:
        model = Job
        fields = ['id', 'user', 'submit_date', 'start_date', 'sbml_file', 'status', 'is_finished', 'time_finished']

        row_attrs = {
            "data-id": lambda record: record.pk
        }
