from django.db.models.signals import post_save
from django.dispatch import receiver
from jobs.models import Job


@receiver(post_save, sender=Job)
def start_job(sender, instance, **kwargs):
    print('Signal post save received!')
    print(instance.user)
