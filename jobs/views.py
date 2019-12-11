from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import JobSubmissionForm, JobTable, JobDetailTable
from django.contrib import messages


@login_required
def new(request):
    job_form = JobSubmissionForm(request.POST or None, request.FILES or None)
    if request.POST:
        if job_form.is_valid():
            extended = job_form.save(commit=False)
            extended.user = request.user
            extended.file = request.FILES
            extended.save()
            return redirect('overview')
    return render(request, 'jobs/new.html', context={'job_form': job_form})


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


@login_required
def details(request, pk):
    job = request.user.job_set.get(id=pk)
    return render(request, 'jobs/details.html', context={'job': job})
