from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job, SubTask
from .tasks import cpu_test, cpu_test_two
from django_celery_results.models import TaskResult
from celery.signals import task_postrun, after_task_publish, task_prerun, task_failure
from celery import chain
from celery.result import AsyncResult
import os
from celery.utils.log import get_task_logger
import logging


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    if created:
        # instance.start_date = timezone.localtime(timezone.now())
        sender.objects.filter(id=instance.id).update(start_date=timezone.now())
        # alternatively: post_save.disconnect(..)
        # instance.save(update_fields=['start_date'])
    instance.refresh_from_db()
    # result = run_training_method.delay()
    # TODO set to queued?
    sender.objects.filter(id=instance.id).update(status='Queued')
    result = chain(cpu_test.s(), cpu_test_two.s(job_id=instance.id)).apply_async(kwargs={'job_id':instance.id})
    # copy = result
    # parents = list()
    # parents.append(copy)
    # while copy.parent:
    #     parents.append(copy.parent)
    #     copy = copy.parent
    #     # TODO check names
    # for parent in parents:
    #     SubTask.objects.create(job=instance, user=instance.user, task_id=parent.id)


@receiver(post_save, sender=TaskResult)
def add_task_info(sender, instance, created, **kwargs):
    task = SubTask.objects.filter(task_id=instance.task_id)
    celery_result = sender.objects.get(task_id=instance.task_id)
    if task:
        name = celery_result.task_name.split('.')[-1]
        date = celery_result.date_done
        task.update(task_result=instance) # , name=name)
        task = task.get()
        Job.objects.filter(id=task.job_id).update(status='Step 2')

    else:
        # couldn't find task - something went wrong during the task
        print('couldnt find task - something went wrong during the task - Is instance ready?')
        print(instance.status)
        print(vars(instance))


@receiver(post_delete, sender=Job)
def after_delete(sender, instance, **kwargs):
    print('After Django delete signal')


@after_task_publish.connect
def task_publish_handler(sender=None, headers=None, body=None, **kwargs):
    # information about task are located in headers for task messages
    # using the task protocol version 2.
    info = headers if 'task' in headers else body
    print('after task publish for task id {info[id]}'.format(
        info=info,
    ))
    # task = SubTask.objects.filter(task_id=info[id])
    # task.update(status_task='RECEIVED')


@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, *args, **kwargs):
    print(f'PRERUN handler setting up logging for {task_id}, {task}, sender {sender}')
    job_id = kwargs['kwargs']['job_id']
    job = Job.objects.get(id=job_id)
    user = job.user
    SubTask.objects.create(job=job, user=user, task_id=task_id, name=task.name)
    fpath = job.sbml_file.path
    path = os.path.dirname(fpath)
    logger = get_task_logger(task_id)#logging.getLogger(task_id)

    formatter = logging.Formatter('[%(asctime)s][%(levelname)s] %(message)s')
    # optionally logging on the Console as well as file
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    stream_handler.setLevel(logging.INFO)
    # Adding File Handle with file path. Filename is task_id
    task_handler = logging.FileHandler(os.path.join(path, task.name+'.log'))
    task_handler.setFormatter(formatter)
    task_handler.setLevel(logging.INFO)
    logger.addHandler(stream_handler)
    logger.addHandler(task_handler)
    logger.info(f'Starting task id {task_id} for task {task.name}')
    # task = SubTask.objects.filter(task_id=task_id)


@task_postrun.connect
def task_postrun_handler(sender, task_id, task, retval, state, *args,  **kwargs):
    print(f'{task_id} exited with status {state}')
    task = SubTask.objects.filter(task_id=task_id)  # returns QuerySet
    job = Job.objects.filter(id=task.get().job_id)
    job.update(is_finished=True)
    # getting the same logger created in prerun handler and closing all handles associated with it
    logger = logging.getLogger(task_id)
    for handler in logger.handlers:
        handler.flush()
        handler.close()
    logger.handlers = []



@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, *args, **kwargs):
    task = SubTask.objects.filter(task_id=task_id)  # returns QuerySet
    # task.update(status_task='FAILURE')
