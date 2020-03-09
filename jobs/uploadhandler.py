from django.core.cache import cache
from django.core.files.uploadhandler import TemporaryFileUploadHandler


def get_progress_id(request):
    progress_id = ''
    if 'X-Progress-ID' in request.GET:
        progress_id = request.GET['X-Progress-ID']
    elif 'X-Progress-ID' in request.META:
        progress_id = request.META['X-Progress-ID']
    return progress_id


class ProgressBarUploadHandler(TemporaryFileUploadHandler):
    """
    Cache system for TemporaryFileUploadHandler
    """
    def __init__(self, *args, **kwargs):
        super(TemporaryFileUploadHandler, self).__init__(*args, **kwargs)
        self.progress_id = None
        self.original_file_name = None

    def handle_raw_input(self, input_data, META, content_length, boundary, encoding=None):
        self.progress_id = get_progress_id(self.request)
        if self.progress_id:
            cache.set(self.progress_id, {
                'size': content_length,
                'status': 'Uploading',
                'received': 0,
                'done': 0,
                'total': 0
            }, 30)

    def new_file(self, *args, **kwargs):
        """
        Create the file object to append to as data is coming in.
        """
        super().new_file(*args, **kwargs)
        self.file.progress_id = self.progress_id
        self.original_file_name = self.file_name

    def receive_data_chunk(self, raw_data, start):
        if self.progress_id:
            data = cache.get(self.progress_id, {})
            data['received'] += self.chunk_size
            cache.set(self.progress_id, data, 30)
        self.file.write(raw_data)

    def upload_complete(self):
        # deprecated in favor of setting an expiry time a-la-nginx
        # setting an expiry time fixes the race condition in which the last
        # progress request happens after the upload has finished meaning the
        # bar never gets to 100%
        pass
        #if self.cache_key:
        #    cache.delete(self.cache_key)