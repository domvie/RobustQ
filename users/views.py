from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import UserRegisterForm
from django.contrib.auth.decorators import login_required


def register(request):
    form = UserRegisterForm(request.POST or None)  # fill form either with POST data else leave it empty
    if form.is_valid():
        form.save()  # if form is valid, django's ORM saves the data to the database
        username = form.cleaned_data.get('username')
        messages.success(request, f'Your account has been created! You are now able to log in.')
        return redirect('login')
    else:
        messages.error(request, f'There was an error creating your account!')

    return render(request, 'users/register.html', {'form': form})


@login_required
def profile(request):
    return render(request, 'users/profile.html')