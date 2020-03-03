from django.contrib.auth.models import User
from django.dispatch import receiver
from django.contrib.auth.signals import user_logged_in
from ipware import get_client_ip
from .models import UserHistory


@receiver(user_logged_in, sender=User)
def tracker(sender, user, request, **kwargs):
    """saves client IP"""
    client_ip, is_routable = get_client_ip(request)
    UserHistory.objects.create(user=user, ip=client_ip)