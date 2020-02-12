from django import forms
from .models import Job
import django_tables2 as tables
from django.utils import timezone
import itertools
from .models import user_directory_path, FileExtensionValidator
from .validators import sbml_validator


class JobSubmissionForm(forms.ModelForm):

    # sbml_file = forms.FileField(validators=[FileExtensionValidator(allowed_extensions=['sbml', 'xml'],
    #                                                                 message='Wrong file type!'), sbml_validator])
    class Meta:
        model = Job
        fields = ['sbml_file', 'compression', 'cardinality']

    def __init__(self, *args, **kwargs):
        super(JobSubmissionForm, self).__init__(*args, **kwargs)
        self.fields['sbml_file'].widget.attrs.update({'class': 'custom-file-input',
                                                      'aria-describedby': 'id_sbml_file_Addon01',
                                                      'data-toggle': 'popover',
                                                      'title': 'Upload a valid model',
                                                      'data-content': ''})
        self.fields['cardinality'].widget.attrs.update({'style': 'width: 3.5rem;',
                                                        'min': '1',
                                                        'max': '5',
                                                        'value': '2',
                                                        'step': '1'})


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
        fields = ['id', 'start_date', 'sbml_file', 'status', 'finished_date', 'result', 'compression', 'cardinality',
                  'details']

        attrs = {
            'class': 'table table-sm table-striped table-hover',
        }
        order_by = "-id"
        # row_attrs = {
        #     "href": lambda record: "jobs/details/"+str(record.pk)
        # }
