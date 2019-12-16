from celery import Celery

app = Celery('tasks', broker='amqp://localhost//')

# from multiprocessing import Pool
from billiard.pool import Pool
from multiprocessing import cpu_count
import time
import random

stop_loop = 0

def exit_chld(x, y):
    global stop_loop
    stop_loop = 1

# signal.signal(signal.SIGINT, exit_chld)

def f(x):
    global stop_loop
    while not stop_loop:
        x * x

@app.task
def add():
    processes = cpu_count() - 1
    print('-' * 20)
    print('Running load on CPU(s)')
    print('Utilizing %d cores' % processes)
    print('-' * 20)
    try:
        pool = Pool(processes)
        # threading.Thread(target=thread_func, args=(pool, 7)).start()
        print("inside process")
        pool.map(f, range(processes))
        print("after map")
        print("after function")
        pool.close()
        pool.join()
        pass
    except KeyboardInterrupt:
        print("caught keyboardinterrupt")
        pool.terminate()
        pool.close()
        pool.join()

@app.task
def run_training_method():
    print('Inside task!')
    result = random.randint(1,10)
    print(f'Sleeping for {result}s')
    time.sleep(result)
    return result
