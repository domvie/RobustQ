from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from .forms import JobTable


@login_required
def overview(request):
    jobs = request.user.job_set.all()
    table = JobTable(jobs)
    running_jobs = jobs.filter(is_finished='False')
    context = {'jobs': jobs,
               'running_jobs': running_jobs,
               'table': table
               }
    return render(request, 'jobs/overview.html', context=context)

