from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import JobSubmissionForm, JobTable
from django.views.generic import CreateView, DetailView, ListView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from .models import Job, SubTask
from ipware import get_client_ip
from django.forms.models import model_to_dict
from django.http import HttpResponse, HttpResponseForbidden, JsonResponse
from django_celery_results.models import TaskResult
from celery.result import AsyncResult
from django_tables2.views import SingleTableView
from django.conf import settings
from django.template.defaultfilters import filesizeformat
from .tasks import get_current_task

# @login_required
# def new(request):
#     job_form = JobSubmissionForm(request.POST or None, request.FILES or None)
#     if request.POST:
#         print('INSIDE FUNC(POST)')
#         print(request.FILES['file'])
#         if job_form.is_valid():
#             extended = job_form.save(commit=False)
#             extended.user = request.user
#             extended.file = request.FILES
#             extended.save()
#             return redirect('jobs')
#     return render(request, 'jobs/new.html', context={'job_form': job_form})


class NewJobView(LoginRequiredMixin, CreateView):
    model = Job
    template_name = 'jobs/new.html'
    form_class = JobSubmissionForm
    context_object_name = 'job_form'

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
    # paginate_by = 10
    model = Job
    template_name = 'jobs/overview.html'
    form_class = JobTable
    table_class = JobTable

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super().get_context_data(**kwargs)
        jobs = self.request.user.job_set.all()
        self.table = JobTable(jobs)
        # table.paginate(self.request.GET.get("page", 1), per_page=25)
        # context['table'] = self.table
        context['running_jobs'] = jobs.filter(is_finished='False')
        context['jobs'] = jobs
        return context


class JobDetailView(LoginRequiredMixin, UserPassesTestMixin, DetailView):
    model = Job
    template_name = 'jobs/details.html'

    def test_func(self):
        job = self.get_object()
        return True if self.request.user == job.user else False

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super().get_context_data(**kwargs)
        job = context['object']
        job_dict = model_to_dict(job)
        job_dict['user'] = self.request.user
        job_dict.pop('ip')
        context['job'] = job_dict
        subtasks = job.subtask_set.all()
        if subtasks:
            context['tasks'] = [model_to_dict(t) for t in subtasks]
            for d in context['tasks']:
                d.pop('id')
                d.pop('user')
                d.pop('job')
                # if d.get('task_result'):
                #     d.update(('task_result', model_to_dict(task.task_result, fields=['status', 'name'])) for task in subtasks)
                    # d['task_result']['task_name'] = d['task_result']['task_name'].split('.')[-1]

                # else:
                #     d['task_result'] = {'status':'No result yet.'}
                try:
                    taskresult = TaskResult.objects.get(task_id=d['task_id'])
                    d['task_result'] = model_to_dict(taskresult, fields=['status', 'result'])
                    d['task_result']['result'] = taskresult.result
                    d['task_result']['date_done'] = taskresult.date_done.strftime("%b %d %Y, %H:%M")
                except Exception as e:
                    task = AsyncResult(d['task_id'])
                    d['status'] = task.status
                    # raise e

        return context


class JobDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Job

    def test_func(self):
        job = self.get_object()
        return True if self.request.user == job.user else False

    success_url = '/'


# @login_required
# def overview(request):
#     jobs = request.user.job_set.all()
#     table = JobTable(jobs)
#     running_jobs = jobs.filter(is_finished='False')
#     context = {'jobs': jobs,
#                'running_jobs': running_jobs,
#                'table': table
#                }
#     return render(request, 'jobs/overview.html', context=context)
#
#
# @login_required
# def details(request, pk):
#     job = request.user.job_set.get(id=pk)
#     return render(request, 'jobs/details.html', context={'job': job})

@login_required
def cancel_job(request, pk):
    job = Job.objects.get(id=pk)

    if not request.user == job.user:
        return HttpResponseForbidden
    if job.is_finished:
        return redirect('index-home')

    try:
        current_task = get_current_task()
        print(current_task)
    except KeyError:
        return JsonResponse({'not found': True})

    subtasks = SubTask.objects.filter(job_id=pk)
    for task in subtasks:
        taskstatus = task.task_result.status
        if taskstatus == 'PENDING':
            res = AsyncResult(task.id)
            print(task.id)
            # res.revoke(terminate=True)
            return JsonResponse({'success':True})



    # json = serialize('json', {'job': pk})
    return JsonResponse({'0': 0})