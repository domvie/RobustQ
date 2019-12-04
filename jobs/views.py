from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail


@login_required
def overview(request):
    # send_mail('testsubject',
    #           'message',
    #           '',
    #           ['dominic.viehbock@gmail.com'],
    #           fail_silently=False,
    #           )
    return render(request, 'jobs/overview.html')

