from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job
from .tasks import add, run_training_method


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    print("Start job signal received")
    if created:
        # instance.start_date = timezone.localtime(timezone.now())
        sender.objects.filter(id=instance.id).update(start_date=timezone.now())
        # alternatively: post_save.disconnect(..)
        # instance.save(update_fields=['start_date'])
    instance.refresh_from_db()
    print("Time job started: ", instance.start_date)
    print('Starting celery task')
    # result = run_training_method.delay()
    result = add.delay(id=instance.id)


@receiver(post_delete, sender=Job)
def after_delete(sender, instance, **kwargs):
    print('After delete signal')