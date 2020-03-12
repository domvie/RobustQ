from django import forms
from .models import Job
import django_tables2 as tables
from django.utils import timezone
from django.utils.html import format_html
import itertools
from django.conf import settings


class JobSubmissionForm(forms.ModelForm):
    """Job submission form class. Details on how to render the form based on the Job model"""
    class Meta:
        model = Job
        fields = ['sbml_file', 'compression', 'cardinality_defigueiredo', 'cardinality_pof', 'make_consistent']

    def __init__(self, *args, **kwargs):
        super(JobSubmissionForm, self).__init__(*args, **kwargs)
        self.fields['sbml_file'].widget.attrs.update({'class': 'custom-file-input',
                                                      'aria-describedby': 'id_sbml_file_Addon01',
                                                      'data-toggle': 'popover',
                                                      'data-content': '',
                                                      'multiple': True,
                                                      'accept': '.' + ',.'.join(settings.ALLOWED_EXTENSIONS) + ', ' +
                                                                ', '.join(settings.ALLOWED_CONTENT_TYPES)})
        self.fields['cardinality_defigueiredo'].widget.attrs.update({'style': 'width: 3.5rem;',
                                                        'min': '1',
                                                        'max': '5',
                                                        'value': '2',
                                                        'step': '1'})
        self.fields['cardinality_pof'].widget.attrs.update({'style': 'width: 3.5rem;',
                                                                'min': '1',
                                                                'max': '20',
                                                                'value': '10',
                                                                'step': '1'})


class JobTable(tables.Table):
    """represents the overview table. Methods mainly on how and what to render"""
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

    def render_duration(self, value):
        if value is None:
            return '—'
        try:
            hours, remainder = divmod(value.total_seconds(), 3600)
            minutes, seconds = divmod(remainder, 60)
            duration = '{:02}:{:02}:{:02}'.format(int(hours), int(minutes), int(seconds))
            return duration
        except Exception:
            return value

    def render_result(self, value):
        if value is None:
            return '—'
        try:
            return round(float(value), 4)
        except:
            return value

    def render_status(self, value):
        if value is None:
            return '—'
        if value == 'Queued':
            return format_html('<span class="badge badge-info" style="border-radius: 8px;">Queued</div>')
        elif value == 'Done':
            return format_html('<span class="badge badge-success" style="border-radius: 8px;">Done</div>')
        elif value == 'Failed':
            return format_html('<span class="badge badge-danger" style="border-radius: 8px;">Failed</div>')
        elif value == 'Cancelled':
            return format_html('<span class="badge badge-warning" style="border-radius: 8px;">Cancelled</div>')
        elif value == 'Started':
            return format_html('<span class="badge badge-primary" style="border-radius: 8px;">Started</div>')
        else:
            return value
    id = tables.LinkColumn('details', args=[tables.utils.A('pk')], text=lambda record: record.pk)
    details = tables.TemplateColumn(template_name="jobs/tables/details.html", extra_context={'label': 'Details'},
                                    verbose_name='', orderable=False, attrs={"td": {"class": "d-flex justify-content-center"}})

    class Meta:
        model = Job
        fields = ['id', 'status', 'sbml_file', 'start_date', 'compression', 'cardinality_defigueiredo',
                  'cardinality_pof', 'make_consistent', 'result', 'duration', 'details']

        attrs = {
            'class': 'table table-sm table-striped table-hover table-sortable',
            'data-toggle': 'table',
            "th": {
                "_ordering": {
                    "orderable": "sortable",  # Instead of `orderable`
                    # "ascending": "ascend",  # Instead of `asc`
                    # "descending": "descend"  # Instead of `desc`
                },
                "class": "text text-center",
            },
            "td": {"class": "text text-center"}
        }
        order_by = "-id"
