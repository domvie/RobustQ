from functools import wraps
from celery.result import AsyncResult
from celery.utils.log import get_task_logger


class RevokeChainRequested(Exception):
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
            return a_shared_task(self, *args, **kwargs)
        except RevokeChainRequested as e:
            # Drop subsequent tasks in chain (if not EAGER mode)
            # if self.request.callbacks:
            #     self.request.callbacks = None
            if self.request.chain:
                self.request.chain = None
            res = AsyncResult(self.request.id)
            res.revoke()
            logger = get_task_logger(self.request.id)
            logger.error(e.return_value)
            raise e

    return inner
