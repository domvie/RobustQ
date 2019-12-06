from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail
from .forms import JobSubmissionForm
from django.contrib import messages
from .models import Job

@login_required
def overview(request):
    jobs = Job.objects.filter(user=request.user)
    return render(request, 'jobs/overview.html', context={'jobs': jobs})


@login_required
def new(request):
    form = JobSubmissionForm(request.POST, request.FILES or None)
    if request.POST:
        if form.is_valid():
            extended = form.save(commit=False)
            extended.user = request.user
            extended.file = request.FILES
            extended.save()

        else:
            messages.warning(request, message='Something went wrong')
            print(form)
            print(form.errors)
            print(form.fields)
            print(form.data)
    return render(request, 'jobs/new.html', context={'form': form})
