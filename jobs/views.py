from django.shortcuts import render
from django.http import HttpResponse


def overview(request):
    return HttpResponse('Overview comes here soon')