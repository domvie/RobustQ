from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job
from .tasks import add, run_training_method


# from multiprocessing import Pool
# from multiprocessing import cpu_count
# import threading
# import signal
#
# stop_loop = 0
#
#
# def exit_chld(x, y):
#     global stop_loop
#     stop_loop = 1
#
#
# signal.signal(signal.SIGINT, exit_chld)
#
# processes = cpu_count() - 1
#
#
# def f(x):
#     print('-' * 20)
#     print('Running load on CPU(s)')
#     print('Utilizing %d cores' % processes)
#     print('-' * 20)
#
#     global stop_loop
#     while not stop_loop:
#         x * x
#
#
# def thread_func(pool, processes):
#     print("inside process")
#     pool.map(f, range(processes))
#     print("after map")


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    print("Start job signal")
    if created:
        instance.start_date = timezone.localtime(timezone.now())
        instance.save(update_fields=['start_date'])
        print("Start time updated.")
    instance.refresh_from_db()
    print("It is now", instance.start_date)
    print('Starting celery task')
    result = run_training_method.delay()
    # try:
        # pool = Pool(processes)
        # threading.Thread(target=thread_func, args=(pool, 7)).start()
        #
        # print("inside thread")
    #     pass
    # except KeyboardInterrupt:
    #     print("caught keyboardinterrupt")
    #     pool.terminate()
    #     pool.close()
    #     pool.join()

@receiver(post_delete, sender=Job)
def after_delete(sender, instance, **kwargs):
    print('After delete signal')