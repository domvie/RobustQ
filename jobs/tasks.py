from __future__ import absolute_import, unicode_literals
from celery import shared_task, Task
from .models import Job

# app = Celery('tasks', backend='rpc://', broker='amqp://localhost//')

# from multiprocessing import Pool
from billiard.pool import Pool
from multiprocessing import cpu_count
import time
import random
from django.utils import timezone


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
        pool = get_pool()
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


class RobustQProcess:

    ignore_result = True

    def __init__(self, instance_id):
        self.processes = cpu_count()-1
        self.pool = Pool(self.processes)
        self.instance = Job.objects.filter(id=instance_id)

    def task(self):
        self.result = add.delay(3)
        return self.result
        # return self.pool.map_async(self.task, range(self.processes))

    def stop_task(self):
        self.pool.terminate()