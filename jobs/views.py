from django.shortcuts import redirect
from django.urls import reverse_lazy
from django.contrib.auth.decorators import login_required
from .forms import JobSubmissionForm, JobTable
from django.views.generic import CreateView, DetailView, ListView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.views.generic.edit import FormMixin
from .models import Job
from ipware import get_client_ip
from django.forms.models import model_to_dict
from django.http import HttpResponse, HttpResponseForbidden, JsonResponse, FileResponse
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


class NewJobView(LoginRequiredMixin, CreateView, FormMixin):
    """Class based view for creating a new job (input form)"""
    model = Job
    template_name = 'jobs/new.html'
    form_class = JobSubmissionForm
    context_object_name = 'job_form'
    success_url = reverse_lazy('jobs')

    def get_success_url(self):
        return '/jobs/'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['job_form'] = context['form']
        context['max_upload'] = filesizeformat(settings.MAX_UPLOAD_SIZE)
        return context

    def form_valid(self, form):
        client_ip, is_routable = get_client_ip(self.request)
        form.instance.user = self.request.user
        form.instance.ip = client_ip
        return super().form_valid(form)


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

        # # Get number of queued jobs # TODO this is currently slow and not worth it
        # # first, get the number in the message broker queue
        # try:
        #     with app.connection_or_acquire() as conn:
        #         context['jobs_queued'] = conn.default_channel.queue_declare(
        #             queue='jobs', passive=True).message_count
        # except:
        #     context['jobs_queued'] = 0
        # try: # then get the tasks that have been sent to the worker but have not been executed yet
        #     reserved_tasks = app.control.inspect().reserved()
        #     nr_jobs_sent_to_worker = len(list(reserved_tasks.values())[0])
        # except AttributeError:  # when value is None (celery not running e.g.)
        #     nr_jobs_sent_to_worker = 0
        # if context['jobs_queued']:
        #     context['jobs_queued'] += nr_jobs_sent_to_worker
        # elif nr_jobs_sent_to_worker != 0:
        #     context['jobs_queued'] = nr_jobs_sent_to_worker

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
        job_dict['user'] = self.request.user
        job_dict.pop('ip')
        to_pop = []
        context['rt'] = job_dict.pop('result_table')
        for k, v in job_dict.items():
            if v is None:
                to_pop.append(k)
        for k in to_pop:
            job_dict.pop(k)

        context['job'] = job_dict

        subtasks = job.subtask_set.all()
        if subtasks:
            context['tasks'] = [model_to_dict(t) for t in subtasks]
            for d in context['tasks']:
                d.pop('id')
                d.pop('user')
                d.pop('job')

                d['logfile'] = {}
                try:
                    with open(d['logfile_path'], 'r') as l:
                        d['logfile']['logdata'] = l.readlines()

                    l.close()

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
        task_id_job = job.task_id_job
        result = AbortableAsyncResult(task_id_job)
        # terminate the running and all subsequent tasks
        # calling abort() and/or revoke() on this result will result in a cascade of revokes of uncompleted tasks
        # as in the execute_pipeline() task all chain tasks get called .revoke() on them
        print(f'REVOKING JOB {task_id_job}')
        result.abort()
        result.revoke(terminate=True)
        if job.status != 'Cancelled':  # should be set to cancelled in task_revoked_handler (signals)
            job = Job.objects.filter(id=pk)
            job.update(status="Cancelled", is_finished=True)

        # Get the currently running task/job set by the task_prerun_handler (signals.py)
        current_task = cache.get('current_task')
        current_job = cache.get('current_job')  # more reliable than 'running_job'
        # as running_job is only set by exec_pipline task

        if current_job == pk:  # make sure we dont kill the running task from the wrong view
            # kill the process with the pid - this is only applicable for subprocesses spawned by the worker with Popen
            pid = cache.get("running_task_pid")
            if pid is not None:
                try:
                    os.kill(pid, 0) # check if it is still running - fails pretty much for all non-subprocess tasks
                except OSError:
                    pass
                else:
                    try:
                        os.kill(pid, signal.SIGKILL)  # if it is running, kill it
                    except ProcessLookupError:
                        pass

    except KeyError:
        return JsonResponse({'not found': True})

    return JsonResponse({'0': 0})


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
    data = jobs.values('model_name', 'result', 'cardinality', 'compression', 'make_consistent', 'reactions',
                       'metabolites', 'genes', 'objective_expression', 'duration')
    df = pd.DataFrame.from_records(data)

    if type == 'csv':
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename=results.csv'

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
def download_job(request, pk):
    """Returns: FileResponse
    Serves a zip file with all logs/files from a job"""
    job = Job.objects.get(id=pk)
    if not request.user == job.user:
        return HttpResponseForbidden
    filename = f'RobustQ_{pk}_{job.model_name}'
    zipf = shutil.make_archive(filename, 'zip', os.path.dirname(job.sbml_file.path))
    zipf_ = open(zipf, 'rb')
    response = FileResponse(zipf_)
    os.remove(zipf)
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