from django import forms
from .models import Job
import django_tables2 as tables
from django.utils import timezone
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


class JobTable(tables.Table):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.counter = itertools.count(start=1)

    def render_start_date(self, value):
        if value is None:
            return '—'
        try:
            return timezone.localtime(value).strftime("%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    def render_submit_date(self, value):
        if value is None:
            return '—'
        try:
            return timezone.localtime(value).strftime("%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    def render_finished_date(self, value):
        if value is None:
            return '—'
        try:
            return timezone.localtime(value).strftime("%b %d %Y, %H:%M")
        except TypeError as te:
            return '—'

    id = tables.LinkColumn('details', args=[tables.utils.A('pk')], text=lambda record: record.pk)
    details = tables.TemplateColumn(template_name="jobs/tables/details.html", extra_context={'label': 'Details'},
                                    verbose_name='')


    class Meta:
        model = Job
        fields = ['id', 'user', 'submit_date', 'start_date', 'sbml_file', 'status', 'finished_date',
                  'details']

        attrs = {
            'class': 'table table-striped table-hover'
        }
        # row_attrs = {
        #     "href": lambda record: "jobs/details/"+str(record.pk)
        # }
