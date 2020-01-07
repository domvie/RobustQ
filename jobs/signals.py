from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from jobs.models import Job, SubTask
from .tasks import add, run_training_method, cancel_add, cpu_test, cpu_test_two
from django_celery_results.models import TaskResult
from celery.signals import task_postrun, after_task_publish, task_prerun, task_failure
from celery import chain
from celery.result import AsyncResult


@receiver(post_save, sender=Job)
def start_job(sender, instance, created, **kwargs):
    if created:
        # instance.start_date = timezone.localtime(timezone.now())
        sender.objects.filter(id=instance.id).update(start_date=timezone.now())
        # alternatively: post_save.disconnect(..)
        # instance.save(update_fields=['start_date'])
    instance.refresh_from_db()
    # result = run_training_method.delay()
    sender.objects.filter(id=instance.id).update(status='Running')
    result = chain(cpu_test.s(id=instance.id), cpu_test_two.s(id=instance.id)).apply_async()
    copy = result
    parents = list()
    parents.append(copy)
    while copy.parent:
        parents.append(copy.parent)
        copy = copy.parent
        # TODO check names
    for parent in parents:
        SubTask.objects.create(job=instance, user=instance.user, task_id=parent.id)
                               #status_task=parent.status, name=parent.name)


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
        print('Is instance ready?')
        print(instance.status)
        print(vars(instance))


@receiver(post_delete, sender=Job)
def after_delete(sender, instance, **kwargs):
    print('After Django delete signal')


@after_task_publish.connect(sender='jobs.tasks.cpu_test')
def task_publish_handler(sender=None, headers=None, body=None, **kwargs):
    # information about task are located in headers for task messages
    # using the task protocol version 2.
    info = headers if 'task' in headers else body
    print('after task publish for task id {info[id]}'.format(
        info=info,
    ))
    task = SubTask.objects.filter(task_id=info[id])
    # task.update(status_task='RECEIVED')


@task_postrun.connect
def task_postrun_handler(sender, task_id, task, retval, state, *args,  **kwargs):
    print(f'{task_id} exited with status {state}')
    task = SubTask.objects.filter(task_id=task_id)  # returns QuerySet
    # task.update(status_task=state)
    job = Job.objects.filter(id=task.get().job_id)
    job.update(is_finished=True)


@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, *args, **kwargs):
    print(f'PRERUN handler for {task_id}, {task}, sender {sender}')
    task = SubTask.objects.filter(task_id=task_id)
    # task.update(status_task='STARTED')


@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, *args, **kwargs):
    task = SubTask.objects.filter(task_id=task_id)  # returns QuerySet
    # task.update(status_task='FAILURE')
