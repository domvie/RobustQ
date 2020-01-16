from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job, SubTask
from .tasks import \
    cpu_test, \
    cpu_test_two, \
    update_db_post_run, \
    sbml_processing, \
    compress_network, \
    create_dual_system, \
    defigueiredo
from django_celery_results.models import TaskResult
from celery.signals import task_postrun, after_task_publish, task_prerun, task_failure
from celery import chain
from celery.result import AsyncResult
import os
from celery.utils.log import get_task_logger
import logging
from time import time
import datetime
import sys

timer = {}


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    if created:
        # instance.start_date = timezone.localtime(timezone.now())
        # alternatively: post_save.disconnect(..)
        # instance.save(update_fields=['start_date'])
        pass
    # instance.refresh_from_db()
    # result = run_training_method.delay()
    sender.objects.filter(id=instance.id).update(status='Queued')
    # result = chain(cpu_test.s(),
    #                cpu_test_two.s(job_id=instance.id),
    #                update_db_post_run.s(job_id=instance.id)).apply_async(kwargs={'job_id':instance.id})

    result = chain(sbml_processing.s(job_id=instance.id),
                   compress_network.s(job_id=instance.id),
                   create_dual_system.s(job_id=instance.id),
                   defigueiredo.s(job_id=instance.id),
                   update_db_post_run.s(job_id=instance.id),
                   ).apply_async(kwargs={'job_id':instance.id})

    parents = list()
    parents.append(result)
    while result.parent:
        parents.append(result.parent)
        result = result.parent  # parents is now a list of tasks in the chain
    sender.objects.filter(id=instance.id).update(start_date=timezone.now(), total_subtasks=len(parents))


@receiver(post_save, sender=TaskResult)
def add_task_info(sender, instance, created, **kwargs):
    """ connects TaskResult and SubTask """
    task = SubTask.objects.filter(task_id=instance.task_id)
    if task:
        task.update(task_result=instance)
    else:
        # couldn't find task - something went wrong during the task
        print('couldnt find task post_save - something went wrong during the task - Is instance ready?')


@receiver(post_delete, sender=Job)
def after_delete(sender, instance, **kwargs):
    print('After Django delete signal')


@after_task_publish.connect
def task_publish_handler(sender=None, headers=None, body=None, **kwargs):
    # information about task are located in headers for task messages
    # using the task protocol version 2.
    info = headers if 'task' in headers else body
    # print('after task publish for task id {info[id]}'.format(
    #     info=info,
    # ))
    # task = SubTask.objects.filter(task_id=info[id])
    # task.update(status_task='RECEIVED')


@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, *args, **kwargs):
    print(f'PRERUN handler setting up logging for {task_id}, {task}, sender {sender}')
    timer[task_id] = time()
    job_id = kwargs['kwargs']['job_id']
    job = Job.objects.filter(id=job_id)
    job.update(status="Started")
    job = job.get()
    SubTask.objects.create(job=job, user=job.user, task_id=task_id, name=task.name)

    fpath = job.sbml_file.path
    path = os.path.dirname(fpath)

    logger = get_task_logger(task_id)#logging.getLogger(task_id)
    formatter = logging.Formatter('[%(asctime)s][%(levelname)s] %(message)s')
    # optionally logging on the Console as well as file
    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)
    stream_handler.setLevel(logging.INFO)
    # Adding File Handle with file path. Filename is task_id
    task_handler = logging.FileHandler(os.path.join(path, task.name+'.log'))
    task_handler.setFormatter(formatter)
    task_handler.setLevel(logging.INFO)
    # h = logging.StreamHandler(sys.stdout)
    # logger.addHandler(h)
    logger.addHandler(stream_handler)
    logger.addHandler(task_handler)
    logger.info(f'Starting task id {task_id} for task {task.name}')
    # task = SubTask.objects.filter(task_id=task_id)


@task_postrun.connect
def task_postrun_handler(sender, task_id, task, retval, state, *args,  **kwargs):
    print(f'{task_id} exited with status {state}')
    try:
        cost = time() - timer.pop(task_id)
    except KeyError:
        cost = -1
    # task = SubTask.objects.filter(task_id=task_id)  # returns QuerySet
    # job = Job.objects.filter(id=task.get().job_id)
    # job.update(is_finished=True)
    # getting the same logger created in prerun handler and closilogging.getLoggerng all handles associated with it
    logger = get_task_logger(task_id)
    logger.info("%s ran for %s", task.__name__, str(datetime.timedelta(seconds=cost)))
    logger.info(f'Task {task_id} finished with state {state} and returned {retval}')
    for handler in logger.handlers:
        handler.flush()
        handler.close()
    logger.handlers = []


@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, *args, **kwargs):
    task = SubTask.objects.filter(task_id=task_id).get()
    job = Job.objects.filter(id=task.job.id)
    job.update(status="Failure")
    logger = get_task_logger(task_id)
    logger.error(f'Task {task_id} failed. Exception: {exception}')

