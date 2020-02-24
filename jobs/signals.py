from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job, SubTask
from .tasks import execute_pipeline
from django_celery_results.models import TaskResult
from celery.signals import task_postrun, after_task_publish, task_prerun, task_failure, celeryd_init
from celery import chain
from celery.result import AsyncResult
import os
from celery.utils.log import get_task_logger
import logging
from time import time
import datetime
import sys
from django.core.cache import cache
from django.conf import settings


timer = {}

# signal_tasks = [update_db_post_run, pofcalc, sbml_processing, compress_network, create_dual_system,
#                 defigueiredo, mcs_to_binary]


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    if created:
        pass

    sender.objects.filter(id=instance.id).update(status='Queued')

    id = instance.id
    compression_checked = instance.compression
    cardinality = instance.cardinality
    make_consistent = instance.make_consistent

    execute_pipeline.apply_async(kwargs={'job_id':id,
                                         'compression_checked':compression_checked,
                                         'cardinality':cardinality,
                                         'make_consistent':make_consistent},
                                 queue='jobs')

    # TODO ideas: databasetable with queue, queues, improved lock mechanism,


excluded_tasks = ['jobs.tasks.cleanup_expired_results', 'update_db', 'result_email', 'release_lock',
                  'abort_task']


@receiver(post_save, sender=TaskResult)
def add_task_info(sender, instance, created, **kwargs):
    """ connects TaskResult and SubTask """

    task = SubTask.objects.filter(task_id=instance.task_id)
    if task:
        task.update(task_result=instance)
    else:
        pass


@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, *args, **kwargs):
    if sender.name in excluded_tasks:
        return

    timer[task_id] = time()
    job_id = kwargs['kwargs']['job_id']
    job_qs = Job.objects.filter(id=job_id)
    job = job_qs.get()
    if job.status is not "Done":
        job_qs.update(status="Started")

    cache.set("current_task", task_id, timeout=None) # TODO - doesnt always target correct task
    cache.set('current_job', job_id, timeout=None)

    fpath = job.sbml_file.path
    path = os.path.dirname(fpath)
    path_logs = os.path.join(path, 'logs')
    public_logs = os.path.join(settings.STATICFILES_DIRS[0], 'logs')
    if not os.path.exists(path_logs):
        os.mkdir(path_logs)
    if not os.path.exists(public_logs):
        os.mkdir(public_logs)


    # Set up logging for each task individually
    logger = get_task_logger(task_id) #logging.getLogger(task_id)
    logger.propagate = False
    formatter = logging.Formatter('[%(asctime)s][%(levelname)s] %(message)s')

    # optionally logging on the Console as well as file
    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(logging.Formatter('%(message)s'))
    stream_handler.setLevel(logging.INFO)

    # Adding File Handle with file path. Filename is task_id
    task_handler = logging.FileHandler(os.path.join(path_logs, task.name+'.log'))
    task_handler.setFormatter(formatter)
    task_handler.setLevel(logging.INFO)

    # Adding second File Handle with file path. Filename is task_id
    if not job.public_path:
        public_user_path = os.path.join(public_logs, os.path.relpath(path_logs))
        job_qs.update(public_path=public_user_path)
        if not os.path.exists(public_user_path):
            os.makedirs(public_user_path)

        user_task_logfile_path = os.path.join(public_user_path, task.name+'.log')
    else:
        user_task_logfile_path = os.path.join(job.public_path, task.name+'.log')
    public_log_handler = logging.FileHandler(user_task_logfile_path)
    public_log_handler.setFormatter(formatter)
    public_log_handler.setLevel(logging.INFO)

    logger.addHandler(stream_handler)
    logger.addHandler(task_handler)
    logger.addHandler(public_log_handler)
    logger.info(f'Starting task id {task_id} for task {task.name}')
    # task = SubTask.objects.filter(task_id=task_id)

    SubTask.objects.create(job=job, user=job.user, task_id=task_id, name=task.name, logfile_path=user_task_logfile_path)


@task_postrun.connect
def task_postrun_handler(sender, task_id, task, retval, state, *args,  **kwargs):
    if sender.name in excluded_tasks:
        return

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

    SubTask.objects.filter(task_id=task_id).update(duration=str(datetime.timedelta(seconds=cost)))

    for handler in logger.handlers:
        handler.flush()
        handler.close()
    logger.handlers = []
    if task.__name__ == 'execute_pipeline':
        cache.delete('running_job')
        try:
            job_id = kwargs['kwargs']['job_id']
            Job.objects.filter(id=job_id).update(is_finished=True)
        except:
            pass


@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, *args, **kwargs):
    task = SubTask.objects.filter(task_id=task_id).get()
    job = Job.objects.filter(id=task.job.id)
    job.update(status="Failure", is_finished=True)
    logger = get_task_logger(task_id)
    logger.error(f'Task {task_id} failed. Exception: {exception}')
    cache.delete('running_job')


@celeryd_init.connect
def worker_init(sender, instance, conf, options, **kwargs):
    cache.delete('running_job')