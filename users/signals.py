from django.db.models.signals import post_save
from django.contrib.auth.models import User
from django.dispatch import receiver
from jobs.models import Job
from django.contrib.auth.signals import user_logged_in
from ipware import get_client_ip
from .models import UserHistory


# @receiver(post_save, sender=User)
# def create_job(sender, instance, created, **kwargs):
#     if created:
#         Job.objects.create(user=instance)
#
#
# @receiver(post_save, sender=User)
# def save_job(sender, instance, **kwargs):
#     instance
#     instance.Job.save()


@receiver(user_logged_in, sender=User)
def tracker(sender, user, request, **kwargs):
    client_ip, is_routable = get_client_ip(request)
    UserHistory.objects.create(user=user, ip=client_ip)