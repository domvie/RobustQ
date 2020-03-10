from django.db.models.signals import post_save, pre_delete
from django.dispatch import receiver
from jobs.models import Job, SubTask
from .tasks import execute_pipeline, revoke_job
from django_celery_results.models import TaskResult
from celery.signals import task_postrun, after_task_publish, task_prerun, task_failure, celeryd_init, task_revoked
import os
from celery.utils.log import get_task_logger
import logging
from time import time
import datetime
import sys
from django.core.cache import cache
from django.conf import settings
from celery.result import AsyncResult
from django.utils import timezone

"""All signals connected to task execution are handled here, including celery worker signals
"""

timer = {}  # will be used for tracking task execution times


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    """gets triggered when a job is saved (aka when the user submits a job)
    sends the entire task pipeline to the message queue for execution"""
    if created:  # to avoid recursive calls
        pass

    sender.objects.filter(id=instance.id).update(status='Queued')

    # get params
    id = instance.id
    compression_checked = instance.compression
    cardinality_defi = instance.cardinality_defigueiredo
    cardinality_pof = instance.cardinality_pof
    make_consistent = instance.make_consistent

    # Send the task to the celery worker
    execute_pipeline.apply_async(kwargs={'job_id':id,
                                         'compression_checked':compression_checked,
                                         'cardinality_defi':cardinality_defi,
                                         'cardinality_pof':cardinality_pof,
                                         'make_consistent':make_consistent},
                                 queue='jobs')


#  these tasks are ignored by the signal handlers
excluded_tasks = ['jobs.tasks.cleanup_expired_results', 'update_db', 'result_email', 'release_lock',
                  'abort_task']


@receiver(post_save, sender=TaskResult)
def add_task_info(sender, instance, created, **kwargs):
    """ connects TaskResult and SubTask models """

    task = SubTask.objects.filter(task_id=instance.task_id)
    if task:
        task.update(task_result=instance)
    else:
        pass


@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, *args, **kwargs):
    """gets run before every task is executed by a worker. Mainly to set up logging for every
    individual task, define and save user paths and create the corresponding SubTask object"""
    if sender.name in excluded_tasks:
        return

    # starts the timer - gets popped in postrun_handler
    timer[task_id] = time()

    job_id = kwargs['kwargs']['job_id']

    cache.set("current_task", task_id, timeout=None)
    cache.set('current_job', job_id, timeout=None)

    job_qs = Job.objects.filter(id=job_id)
    job = job_qs.get()

    #  check if aborted
    res = AsyncResult(task_id)
    if res.status == 'REVOKED' or res.status == 'ABORTED':
        return
    if job.status is not "Done" or job.status != 'Cancelled':
        job_qs.update(status="Started", is_finished=False)
    else:
        return

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

    SubTask.objects.create(job=job, user=job.user, task_id=task_id, name=task.name, logfile_path=user_task_logfile_path)


@task_postrun.connect
def task_postrun_handler(sender, task_id, task, retval, state, *args,  **kwargs):
    """As the name suggests, fires after the task is finished by the worker. Log results, exc time,
    cleanup, update states"""
    if sender.name in excluded_tasks:
        return

    print(f'{task_id} exited with status {state}')
    try:
        cost = time() - timer.pop(task_id)
    except KeyError:
        cost = -1
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
    """if a task fails, try to log what happened"""
    task = SubTask.objects.filter(task_id=task_id).get()
    job = Job.objects.filter(id=task.job.id)
    if job.get().status != 'Cancelled':
        job.update(status="Failed")

    finished_date = timezone.now()
    duration = finished_date - job.get().start_date
    hours, remainder = divmod(duration.total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    duration = '{:02}:{:02}:{:02}'.format(int(hours), int(minutes), int(seconds))
    job.update(is_finished=True, duration=duration, finished_date=finished_date)

    logger = get_task_logger(task_id)
    logger.error(f'Task {task_id} failed. Exception: {exception}')
    cache.delete('running_job')


@celeryd_init.connect
def worker_init(sender, instance, conf, options, **kwargs):
    """this removes the lock on the worker (currently useless)"""
    cache.delete('running_job')


@task_revoked.connect(sender="execute_pipeline")
def task_revoked_handler(request, terminated, signum, expired, *args, **kwargs):
    """fires when a task is revoked - i.e. when user it manually or the execution chain fails"""
    job_id = kwargs['job_id']
    print('Task revoke handler: cancelling job ', job_id)
    job = Job.objects.filter(id=job_id)
    job.update(status="Cancelled", is_finished=True)
    AsyncResult(request.id).revoke()
    logger = get_task_logger(request.id)
    logger.warning(f'Task {request.task} for job {job_id} has been flagged as revoked, with terminate={terminated}, '
                   f'signal {signum}, expired: {expired}')


@after_task_publish.connect(sender="execute_pipeline")
def task_sent_handler(sender=None, headers=None, body=None, **kwargs):
    # information about task are located in headers for task messages
    # using the task protocol version 2.
    info = headers if 'task' in headers else body

    try:
        job_id=body[1]['job_id']
        job = Job.objects.filter(id=job_id)
        job.update(task_id_job=info['id'])

    except Exception as e:
        print(repr(e))


@receiver(pre_delete, sender=Job)
def pre_delete_handler(sender, instance, using, *args, **kwargs):
    #  make sure we cancel any celery jobs before deleting
    revoke_job(instance)