from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import UserRegisterForm
from django.contrib.auth import authenticate, login


def register(request):
    form = UserRegisterForm(request.POST or None)  # fill form either with POST data else leave it empty
    if form.is_valid():
        form.save()  # if form is valid, django's ORM saves the data to the database
        messages.success(request, f'Your account has been created!')
        new_user = authenticate(username=form.cleaned_data['username'],
                                password=form.cleaned_data['password1'])
        login(request, new_user)
        return redirect('index-home')
    return render(request, 'users/register.html', {'form': form})