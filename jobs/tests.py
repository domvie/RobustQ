from django.test import TestCase
from .models import Job
from .forms import JobSubmissionForm
from django.urls import reverse
from django.core.files import File


# Create your tests here.
class ViewTest(TestCase):

    def create_whatever(self, title="only a test", body="yes, this is only a test"):
        return Job.objects.create(user_id=1, sbml_file=File('models/ecolitest.xml'))

    def test_whatever_creation(self):
        w = self.create_whatever()
        self.assertTrue(isinstance(w, Job))
        # self.assertEqual(w.__unicode__(), w.title)

    def test_whatever_list_view(self):
        w = self.create_whatever()
        url = reverse("details")
        resp = self.client.get(url)

        self.assertEqual(resp.status_code, 200)
        self.assertIn(w.id, resp.content)