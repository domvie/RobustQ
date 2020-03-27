from django.shortcuts import redirect
from django.urls import reverse_lazy, reverse
from django.contrib.auth.decorators import login_required
from .forms import JobSubmissionForm, JobTable
from django.views.generic import CreateView, DetailView, ListView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.views.generic.edit import FormMixin
from .models import Job, SubTask
from ipware import get_client_ip
from django.forms.models import model_to_dict
from django.http import HttpResponse, HttpResponseForbidden, JsonResponse, FileResponse, HttpResponseRedirect, \
    HttpResponseServerError
from django_celery_results.models import TaskResult
from celery.result import AsyncResult
from django_tables2.views import SingleTableView
from django.conf import settings
from django.template.defaultfilters import filesizeformat
from django.core.cache import cache
from celery.contrib.abortable import AbortableAsyncResult
import signal
import os
from django.utils import timezone
import pandas as pd
import shutil
from io import BytesIO as IO
from zipfile import ZipFile
from django.utils.datastructures import MultiValueDict
from django.core.files.uploadhandler import TemporaryFileUploadHandler
from django.core.validators import ValidationError
from django.contrib import messages
from django.http import StreamingHttpResponse
import time
from jobs.uploadhandler import get_progress_id
from .tasks import revoke_job
from RobustQ.celery import app


def uploadstream(request, user):
    def event_stream():
        while True:
            progress = cache.get('current_upload')
            time.sleep(1)
            yield f'data: {progress} from {request.user.username}\n\n'
    return StreamingHttpResponse(event_stream(), content_type='text/event-stream')


# view that display the current upload progress (json)
def upload_progress(request, uuid):
    """
    Return JSON object with information about the progress of an upload.
    """
    if uuid:
        progress_id = uuid
    else:
        progress_id = get_progress_id(request)
    if progress_id:
        data = cache.get(progress_id, None)
        return JsonResponse(data, safe=False)
    else:
        return HttpResponseServerError('Server Error: You must provide X-Progress-ID header or query param.')


class NewJobMixin(CreateView, FormMixin):
    model = Job
    template_name = 'jobs/new.html'
    form_class = JobSubmissionForm
    context_object_name = 'job_form'
    success_url = reverse_lazy('jobs')
    form_list = []
    object = None
    progress_id = None

    def get_success_url(self):
        return '/jobs/'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['job_form'] = context['form']
        context['max_upload'] = filesizeformat(settings.MAX_UPLOAD_SIZE)
        context['allowed_ext'] = ',.'.join(settings.ALLOWED_EXTENSIONS)
        context['timelimit'] = (settings.CELERY_TASK_TIME_LIMIT)/3600
        context['debug'] = settings.DEBUG
        return context

    # Overriding the post method
    def post(self, request, *args, **kwargs):
        file = request.FILES['sbml_file']
        self.progress_id = file.progress_id
        if len(request.FILES.getlist('sbml_file')) > 1:  # did the user upload multiple files?
            cache.set('current_upload', len(request.FILES.getlist('sbml_file')), timeout=180)
            return self.multi_file_upload_handler(request)

        # only a single file was uploaded - check if its a zip archive first
        # check extension
        filename, ext = os.path.splitext(file.name)
        if ext == '.zip':
            return self.zip_file_handler(request, file)

        if JobSubmissionForm(request.POST).data.get('skip_validation', None) == 'on':
            form = JobSubmissionForm(request.POST, request.FILES)
            form.is_valid()
            form.instance.user = request.user
            form._errors = {}
            form.save()

            return HttpResponseRedirect(self.get_success_url())

        else:
            return super().post(self, request, *args, **kwargs)

    def form_valid(self, form):
        client_ip, is_routable = get_client_ip(self.request)
        form.instance.user = self.request.user
        form.instance.ip = client_ip
        return super().form_valid(form)

    def zip_file_handler(self, request, file):
        """
        called when the user uploads a zip. Creates a new Job object by calling form.save() for each
        sbml file in the archive. We create a new 'fake' form for each file so we can run validation on each
        file separately by calling form.is_valid()
        """
        myzip = ZipFile(file.file)
        failed_files = []

        if myzip.testzip():  # returns something if the zip is faulty
            form = JobSubmissionForm(request.POST, request.FILES)
            form.is_valid()
            print(vars(form.cleaned_data['sbml_file']))
            form.add_error('sbml_file', ValidationError('Could not read archive. It may be corrupted or contain '
                                                        'bad files.'))
            return self.form_invalid(form)

        filelist = myzip.namelist()
        any_form_valid = False
        self.update_cache(zip_total=len(filelist))

        for model in filelist:
            model_name, ext = os.path.splitext(model)
            if ext.replace('.', '') not in settings.ALLOWED_EXTENSIONS:
                continue

            file_size = myzip.getinfo(model).file_size
            file_dict = MultiValueDict()
            temp_file_handler = TemporaryFileUploadHandler(request)  # manually instantiate and create a
            # TempUploadedFile object
            # see https://docs.djangoproject.com/en/3.0/_modules/django/core/files/uploadhandler/

            with myzip.open(model) as f:
                temp_file_handler.new_file(field_name='sbml_file', file_name=os.path.basename(f.name),
                                           content_type='text/xml',
                                           content_length=file_size, charset=None)  # this class now holds our xml file
                temp_file_handler.file.write(f.read())  # write the content to the tempuploadFile, which
                # gets passed to the validators and holds our model file from the zip
            # temp_file_handler.file.seek(0)
            temp_file_handler.file_complete(file_size)  # calls file.seek(0) and sets file.size to file_size
            file_dict['sbml_file'] = temp_file_handler.file
            # InMemoryUploadedFile(f, 'sbml_file', f.name, 'text/xml', file_size, charset='utf-8')
            # manually create a form object from each file in zip
            # file_dict is a MultiValueDict() which holds our file, copying a request.FILES-like object
            temp_form = JobSubmissionForm(request.POST, file_dict)

            if temp_form.fields['skip_validation']:
                # form = JobSubmissionForm(request.POST, request.FILES)
                temp_form.is_valid()
                temp_form.instance.user = request.user
                temp_form._errors = {}
                temp_form.save()
                self.update_cache()
                any_form_valid = True
                continue

            if temp_form.is_valid():  # if the 'form' is valid, save it as a new Job object, thus queueing it up
                temp_form.instance.user = self.request.user
                temp_form.save()
                any_form_valid = True
            else:
                failed_files.append(temp_file_handler.file.name)
            self.update_cache()
        myzip.close()

        if failed_files:
            messages.add_message(request, messages.ERROR, f'File(s) {", ".join(failed_files)} failed SBML '
                                                          f'validation. Try to upload them separately '
                                                          f'to see detailed error messages.')

        return HttpResponseRedirect(self.get_success_url()) if any_form_valid \
            else self.form_invalid(JobSubmissionForm(
                request.POST, request.FILES
            ))

    def multi_file_upload_handler(self, request):
        """
        called when the user uploads multiple file (by selection). Like the zip file handler,
        this saves a new Job object for each file. We create a new 'fake' form for each file so we can run validation on each
        file separately by calling form.is_valid()
        """
        failed_files = []
        any_form_valid = False
        total_files = len(request.FILES.getlist('sbml_file'))
        self.update_cache(total=total_files)

        for file in request.FILES.getlist('sbml_file'):
            _, ext = os.path.splitext(file.name)
            if ext == '.zip':
                self.zip_file_handler(request, file)
            file_dict = MultiValueDict()
            file_dict['sbml_file'] = file
            temp_form = JobSubmissionForm(request.POST, file_dict)
            if temp_form.fields['skip_validation']:
                # form = JobSubmissionForm(request.POST, request.FILES)
                temp_form.is_valid()
                temp_form.instance.user = request.user
                temp_form._errors = {}
                temp_form.save()
                any_form_valid = True
                self.update_cache()
                continue

            if temp_form.is_valid():  # if the 'form' is valid, save it as a new Job object, thus queueing it up
                temp_form.instance.user = self.request.user
                temp_form.save()
                any_form_valid = True
            else:
                failed_files.append(file.name)
            self.update_cache()

        if failed_files:
            messages.add_message(request, messages.ERROR, f'File(s) {", ".join(failed_files)} failed SBML '
                                                          f'validation. Try to upload them separately '
                                                          f'to see detailed error messages.')
        return HttpResponseRedirect(self.get_success_url()) if any_form_valid \
            else self.form_invalid(JobSubmissionForm(
                request.POST, request.FILES
            ))

    def update_cache(self, **kwargs):
        """ essentially adds +1 to total done count / updates cache with kwargs"""
        uuid = self.progress_id
        data = cache.get(uuid, {})
        data['status'] = 'Validating'
        data['total'] += kwargs.pop('total', 0)
        zip_total = kwargs.pop('zip_total', 0)
        data['total'] += zip_total
        data['done'] += 1
        cache.set(uuid, data)


class NewJobView(LoginRequiredMixin, NewJobMixin):
    """Class based view for creating a new job (input form)"""
    pass


class JobOverView(LoginRequiredMixin, SingleTableView, ListView):
    """Class based job overview"""
    # paginate_by = 10
    template_name = 'jobs/overview.html'
    form_class = JobTable
    table_class = JobTable

    def get_queryset(self):
        """ Returns jobs that belong to the current user """
        return self.request.user.job_set.all()

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super().get_context_data(**kwargs)
        jobs = self.request.user.job_set.all()
        self.table = JobTable(jobs)  # -> table defined in forms.py
        context['running_jobs'] = jobs.filter(is_finished='False')
        context['jobs'] = jobs

        return context


class JobDetailView(LoginRequiredMixin, UserPassesTestMixin, DetailView):
    """Class based job detail view"""
    model = Job
    template_name = 'jobs/details.html'

    def test_func(self):
        #  Test function for UserPassesTestMixin
        job = self.get_object()
        return True if self.request.user == job.user else False

    def get_context_data(self, *, object_list=None, **kwargs):
        """Gets all job info (subtasks) to the corresponding user/job, converts them to dict format
        and adds them to template context"""
        context = super().get_context_data(**kwargs)
        job = context['object']
        job_dict = model_to_dict(job)
        to_pop = ['public_path', 'task_id_job', 'ip', 'sbml_file', 'user']
        # to_pop = []
        context['rt'] = job_dict.pop('result_table')
        for k, v in job_dict.items():
            if v is None:
                to_pop.append(k)
        for k in to_pop:
            job_dict.pop(k, None)

        context['job'] = job_dict

        subtasks = job.subtask_set.all()
        if subtasks:
            context['tasks'] = [model_to_dict(t) for t in subtasks]
            for d in context['tasks']:
                # d.pop('id')
                d.pop('user')
                d.pop('job')

                d['logfile'] = {}
                try:
                    with open(d['logfile_path'], 'r') as l:
                        d['logfile']['logdata'] = l.readlines()

                    d['logfile']['path'] = '/' + os.path.relpath(d.pop('logfile_path'))  # settings.STATIC_URL + os.path.join(fpath, f'logs/{d["name"]}.log')

                except TypeError:
                    d['logfile']['logdata'] = 'Could not load logfile'

                try:
                    taskresult = TaskResult.objects.get(task_id=d['task_id'])
                    d['task_result'] = model_to_dict(taskresult, fields=['status', 'result'])
                    d['task_result']['result'] = taskresult.result
                    d['task_result']['date_done'] = timezone.localtime(taskresult.date_done).strftime("%b %d %Y, %H:%M")
                except Exception as e:
                    task = AsyncResult(d['task_id'])
                    d['status'] = task.status
                    # raise e

        return context


class JobDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    """View when User wants to delete a job"""
    model = Job

    def test_func(self):
        # Test function for UserPassesTestMixin
        job = self.get_object()
        return True if self.request.user == job.user else False

    success_url = '/'


@login_required
def cancel_job(request, pk):
    """A view function that cancels the specified job. If its not running,
    it will revoke all celery tasks connected to it; if its currently executing, it
    will revoke any remaining tasks and terminate the running task with os.kill(pid)"""
    job = Job.objects.get(id=pk)

    if not request.user == job.user:
        return HttpResponseForbidden
    if job.is_finished:
        return redirect('index-home')

    try:
        revoke_job(job)
        return HttpResponse(status=204)
    except:
        return HttpResponse('Failed to cancel job', status=400)


@login_required
def cancel_all_jobs(request):
    jobs_to_cancel = Job.objects.filter(user=request.user, is_finished=False)
    if jobs_to_cancel:
        for job in jobs_to_cancel:
            try:
                revoke_job(job)
            except:
                pass
    return redirect('jobs')


@login_required
def download_results(request, type):
    """
    Args:
        request: Django request
        type: (str) 'csv' or 'excel'

    Returns: HttpResponse for file download
    Gathers all results and serves them as a downloadable csv/xl file
    """
    jobs = Job.objects.filter(user=request.user, is_finished=True, status='Done')
    data = jobs.values('model_name', 'result', 'cardinality_mcs', 'cardinality_pof',
                       'compression', 'make_consistent', 'reactions',
                       'metabolites', 'genes', 'objective_expression', 'duration')
    df = pd.DataFrame.from_records(data)

    if type == 'csv':
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename=RobustQ_results_all.csv'

        df.to_csv(path_or_buf=response, sep=';', float_format='%.2f', index=False, decimal=".")
    else:
        xlfile = IO()
        xlwriter = pd.ExcelWriter(xlfile)
        df.to_excel(xlwriter)
        xlwriter.save()
        xlwriter.close()

        # important step, rewind the buffer or when it is read() you'll get nothing
        # but an error message when you try to open your zero length file in Excel
        xlfile.seek(0)

        # set the mime type so that the browser knows what to do with the file
        response = HttpResponse(xlfile.read(),
                                content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename=results.xslx'

    return response


@login_required
def serve_logfile(request, task_id):
    """Returns: FileResponse
    Serves a text/log file from a certain task"""
    task = SubTask.objects.get(id=task_id)
    if not request.user == task.job.user:
        return HttpResponseForbidden
    file = open(task.logfile_path, 'r')
    return FileResponse(file)


@login_required
def download_job(request, pk):
    """Returns: FileResponse
    Serves a zip file with all logs/files from a job"""
    job = Job.objects.get(id=pk)
    if not request.user == job.user:
        return HttpResponseForbidden
    filename = f'RobustQ_{job.model_name}.zip'
    # zipf = shutil.make_archive(filename, 'zip', os.path.dirname(job.sbml_file.path))
    # zipf_ = open(zipf, 'rb')
    response = HttpResponse()
    zipf_ = ZipFile(response, 'w')
    path = os.path.dirname(job.sbml_file.path)
    for root, dirs, files in os.walk(path):
        for file in files:
            zipf_.write(os.path.join(root, file), os.path.relpath(os.path.join(root, file), path))
    zipf_.close()
    response['Content-Disposition'] = 'attachment; filename={}'.format(filename)
    return response


@login_required
def result_table(request, pk, type):
    """
    Args:
        request: Django request
        pk: job id
        type: (str) 'json' or 'csv'

    Returns: Json Http response or HttpResponse with csv file attached (download)
    JSON is for the result table in the detailview (ajax API call)
    CSV for user download
    """
    job = Job.objects.get(id=pk)
    if not request.user == job.user:
        return HttpResponseForbidden
    filename = job.result_table
    if filename:
        if type == 'json':
            return HttpResponse(pd.read_csv(filename).to_json(orient='records', double_precision=15), content_type='application/json')
        else:
            response = HttpResponse(content_type='text/csv')
            response['Content-Disposition'] = f'attachment; filename=result_table_{job.model_name}.csv'

            pd.read_csv(filename).to_csv(path_or_buf=response, sep=';', index=False, decimal=".")
            return response


@login_required
def get_queue(request):
    pass # TODO very ureliable
    # Get number of queued jobs
    # first, get the number in the message broker queue
    try:
        with app.connection_or_acquire() as conn:
            jobs_queued = conn.default_channel.queue_declare(
                queue='jobs', passive=True).message_count
    except:
        jobs_queued = 0
    try: # then get the tasks that have been sent to the worker but have not been executed yet
        reserved_tasks = app.control.inspect().reserved()
        nr_jobs_sent_to_worker = len(list(reserved_tasks.values())[0])
    except AttributeError:  # when value is None (celery not running e.g.)
        nr_jobs_sent_to_worker = 0
    if jobs_queued:
        jobs_queued += nr_jobs_sent_to_worker
    elif nr_jobs_sent_to_worker:
        jobs_queued = nr_jobs_sent_to_worker

    return JsonResponse({'queue': jobs_queued})