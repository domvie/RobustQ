from __future__ import absolute_import, unicode_literals
from celery import shared_task
from .models import Job
from RobustQ.celery import app
# app = Celery('tasks', backend='rpc://', broker='amqp://localhost//')

# from multiprocessing import Pool
from billiard.pool import Pool
from multiprocessing import cpu_count
import time
import random
from django.utils import timezone
import subprocess


def f(x):
    timeout = time.time() + 60
    while True:
        x * x
        if time.time() >= timeout:
            break

pool = None

@shared_task
def get_pool():
    global pool
    if pool is None:
        pool = Pool(cpu_count() - 1)
    return pool


@shared_task
def add(id):
    processes = cpu_count() - 1
    print('-' * 20)
    print('Running load on CPU(s)')
    print('Utilizing %d cores' % processes)
    print('-' * 20)
    instance = Job.objects.filter(id=id)

    try:
        pool = Pool(processes)
        # threading.Thread(target=thread_func, args=(pool, 7)).start()
        print("inside process")
        instance.update(status='Running')
        # return pool.map_async(f, range(processes))
        pool.map(f, range(processes))
        print("after map")
        print("after function")
        pool.close()
        pool.join()
        finished = timezone.now()
        instance.update(finished_date=finished, is_finished=True, status='Done')
        return finished
    except Exception as e:
        return f'Failed! {e.args[1]}'


@shared_task
def cancel_add():
    pool = get_pool()
    print('canceling process pool')
    pool.terminate()
    pool.close()
    pool.join()


@shared_task()
def run_training_method():
    print('Inside task!')
    result = random.randint(3,10)
    print(f'Sleeping for {result}s')
    time.sleep(result)
    return result


@shared_task
def cpu_test(id):
    name = 'cpu_test_one'
    # job = Job.objects.filter(id=id)
    cpu = subprocess.Popen("bin/cpu_fun")
    cpu.wait()
    return cpu.returncode


@shared_task
def cpu_test_two(result=None, id=None):
    print('inside cpu task 2')
    print(f'result of 1 was {result}')
    # job = Job.objects.filter(id=id)
    cpu = subprocess.Popen("bin/cpu_fun")
    cpu.wait()
    return cpu.returncode


@shared_task
def cpu_test_long(id):
    print('ID:', id)
    job = Job.objects.get(id=id)
    cpu = subprocess.Popen("bin/cpu_fun")
    cpu.wait()
    print('Finished with subprocess')