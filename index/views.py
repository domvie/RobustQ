from django.shortcuts import render, redirect
from django.http import HttpResponse
from jobs.forms import JobSubmissionForm
from django.contrib import messages
from crispy_forms.utils import render_crispy_form
from django.template.context_processors import csrf


def home(request):
    context = dict()
    if request.user.is_authenticated:
        form = JobSubmissionForm(request.POST or None, request.FILES or None)
        ctx = {}
        ctx.update(csrf(request))
        form_html = render_crispy_form(form, context=ctx)
        if request.POST:
            if form.is_valid():
                extended = form.save(commit=False)
                extended.user = request.user
                extended.file = request.FILES
                extended.save()
                return redirect('jobs')
        jobs = request.user.job_set.all()
        running_jobs = jobs.filter(is_finished='False')
        context.update({
            'jobs': jobs,
            'running_jobs': running_jobs,
            'job_form': form,
        })
        return render(request, 'index/index.html', context=context)
    else:
        return render(request, 'index/index.html')  # return this if user is not authenticated


def about(request):
    return HttpResponse('<h1>About</h1>')