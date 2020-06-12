from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.urls import reverse_lazy
from jobs.forms import JobSubmissionForm
from django.conf import settings
from django.template.defaultfilters import filesizeformat
from jobs.views import NewJobMixin
from jobs.models import Job
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import TemplateView


# # TODO class based view
# def home(request):
#     context = dict()
#     if request.user.is_authenticated:
#         form = JobSubmissionForm(request.POST or None, request.FILES or None)
#         # ctx = {}
#         # ctx.update(csrf(request))
#         jobs = request.user.job_set.all()
#         running_jobs = jobs.filter(is_finished='False')
#         context.update({
#             'jobs': jobs,
#             'running_jobs': running_jobs,
#             'job_form': form,
#             'max_upload': filesizeformat(settings.MAX_UPLOAD_SIZE)
#         })
#         if request.POST:
#             if form.is_valid():
#                 extended = form.save(commit=False)
#                 extended.user = request.user
#                 extended.file = request.FILES
#                 extended.save()
#                 return redirect('jobs')
#     return render(request, 'index/index.html', context=context)


def about(request):
    return HttpResponse('<h1>About</h1>')


class IndexView(NewJobMixin):

    template_name = 'index/index.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data()
        if self.request.user.is_authenticated:
            jobs = self.request.user.job_set.all()
            running_jobs = jobs.filter(is_finished='False')
            context['running_jobs'] = running_jobs
            context['jobs'] = jobs
        return context


class HelpView(TemplateView):

    template_name = 'index/help.html'


class PublicationsView(TemplateView):

    template_name = 'index/publications.html'


class PrivacyView(TemplateView):

    template_name = 'index/privacy.html'