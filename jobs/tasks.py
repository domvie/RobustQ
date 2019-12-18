from celery import Celery
from .models import Job

app = Celery('tasks', broker='amqp://localhost//')

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


@app.task
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

@app.task()
def run_training_method():
    print('Inside task!')
    result = random.randint(3,10)
    print(f'Sleeping for {result}s')
    time.sleep(result)
    return result


