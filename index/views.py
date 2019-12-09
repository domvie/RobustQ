from django.shortcuts import render, redirect
from django.http import HttpResponse
from jobs.forms import JobSubmissionForm
from django.contrib import messages


def home(request):
    if request.user.is_authenticated:
        form = JobSubmissionForm(request.POST or None)  # fill form either with POST data else leave it empty
        if form.is_valid():
            form.save()  # if form is valid, django's ORM saves the data to the database
            return redirect('jobs')
        else:
            messages.error(request, f'There was an error! {form.data} '
                                    f'Data: {form.cleaned_data}'
                                    f'Errors: {form.errors}'
                                    f'{list(field for field in form.fields) }')
        jobs = request.user.job_set.all()
        running_jobs = jobs.filter(is_finished='False')
        context = {
            'jobs': jobs,
            'running_jobs': running_jobs,
            'job_form': JobSubmissionForm,
        }
        return render(request, 'index/index.html', context=context)
    else:
        return render(request, 'index/index.html')


def about(request):
    return HttpResponse('<h1>About</h1>')