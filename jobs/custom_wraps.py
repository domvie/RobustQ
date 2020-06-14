from functools import wraps
from celery.result import AsyncResult
from celery.contrib.abortable import AbortableAsyncResult
from celery.utils.log import get_task_logger
from django.core.cache import cache
import os
import signal
from celery.exceptions import TimeLimitExceeded

"""custom revoke chain Exception"""


class ExecutionAbortedError(Exception):
    def __init__(self, return_value):
        Exception.__init__(self, "")

        self.return_value = return_value


def revoke_chain_authority(a_shared_task):
    """
    @see: https://gist.github.com/bloudermilk/2173940
    @param a_shared_task: a @shared_task(bind=True) celery function.
    @return:
    """
    @wraps(a_shared_task)
    def inner(self, *args, **kwargs):
        try:
            # 'begin second wrap
            return a_shared_task(self, *args, **kwargs)
        except ExecutionAbortedError as e:
            # Drop subsequent tasks in chain (if not EAGER mode)
            # if self.request.callbacks:
            #     self.request.callbacks = None
            if self.request.chain:
                self.request.chain = None

            res = AbortableAsyncResult(self.request.id)
            job_id = cache.get('current_job')
            job_task = kwargs.get('job_id')

            if job_id == job_task:
                try:
                    pid = cache.get(f'pipeline_{job_id}').get('pid')
                    if pid:
                        os.kill(pid, signal.SIGTERM)
                except:
                    pass
            try:
                res.abort()
            except:
                res.revoke()

            raise e
        except TimeLimitExceeded as e:
            if self.request.chain:
                self.request.chain = None
            res = AbortableAsyncResult(self.request.id)
            res.abort()
            logger = get_task_logger(self.request.id)
            logger.error('Time limit exceeded for task!')
            try:
                job_id = kwargs.get('job_id')
                os.kill(cache.get(f'pipeline_{job_id}').get('pid'), signal.SIGKILL)
            except:
                pass
            raise e

    return inner


def test(taski):
    @wraps(taski)
    def inner(self, *args, **kwargs):
        # 'In first wrap begin'
        return taski(self, *args, **kwargs)
    return inner