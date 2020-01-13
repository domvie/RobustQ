from __future__ import absolute_import, unicode_literals
from celery import shared_task
from .models import Job, SubTask
from RobustQ.celery import app
# from multiprocessing import Pool
from billiard.pool import Pool
from multiprocessing import cpu_count
import time
import random
from django.utils import timezone
import subprocess
from celery.utils.log import get_task_logger


def log_subprocess_output(pipe, logger=None):
    for line in iter(pipe.readline, b''): # b'\n'-separated lines
        logger.info('%r', line.decode('utf-8'))


@shared_task(bind=True, name='cpu_test_one')
def cpu_test(self, *args, **kwargs):
    logger = get_task_logger(self.request.id)
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {self.request.kwargs}')
    cpu = subprocess.Popen("bin/cpu_fun", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with cpu.stdout:
        log_subprocess_output(cpu.stdout, logger=logger)
    cpu.wait()
    # stdout = cpu.communicate()[0]
    # logger.info(stdout)
    return cpu.returncode


@shared_task(bind=True, name='cpu_test_two')
def cpu_test_two(self, result=None, *args, **kwargs):
    print('inside cpu task 2')
    logger = get_task_logger(self.request.id)
    logger.info(f'Result of previous task was {result}')
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {self.request.kwargs}')
    cpu = subprocess.Popen("bin/cpu_fun", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with cpu.stdout:
        log_subprocess_output(cpu.stdout, logger=logger)
    cpu.wait()
    # stdout = cpu.communicate()[0]
    # logger.info(stdout)
    # job = Job.objects.filter(id=id)
    return cpu.returncode


@shared_task
def cpu_test_long(id):
    print('ID:', id)
    job = Job.objects.get(id=id)
    cpu = subprocess.Popen("bin/cpu_fun")
    cpu.wait()
    print('Finished with subprocess')


from celery.contrib import rdb # debugger


@shared_task(bind=True)
def update_db_post_run(self, result=None, job_id=None, *args, **kwargs):
    job = Job.objects.filter(id=job_id)
    job.update(is_finished=True, finished_date=timezone.now(), status="Done", result=result)
