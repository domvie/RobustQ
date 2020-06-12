"""RobustQ URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from users import views as user_views
from jobs import views as job_views
from django.contrib.auth import views as auth_views
from index import views as index_views
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('index.urls')),
    path('register/', user_views.register, name='register'),
    path('help/', index_views.HelpView.as_view(), name='help'),
    path('publications/', index_views.PublicationsView.as_view(), name='publications'),
    path('privacy/', index_views.PrivacyView.as_view(), name='privacy'),
    path('login/', auth_views.LoginView.as_view(template_name='users/login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(template_name='users/logout.html'), name='logout'),
    path('jobs/', job_views.JobOverView.as_view(), name='jobs'),
    path('jobs/new/', job_views.NewJobView.as_view(), name='new'),
    path('jobs/details/<int:pk>', job_views.JobDetailView.as_view(), name='details'),
    path('jobs/delete/<int:pk>', job_views.JobDeleteView.as_view(), name='job-delete'),
    path('jobs/cancel/<int:pk>', job_views.cancel_job, name='cancel'),
    path('jobs/download_results/<str:type>', job_views.download_results, name='download_results'),
    path('jobs/download_job/<int:pk>', job_views.download_job, name='download_job'),
    path('jobs/result_table/<int:pk>/<str:type>', job_views.result_table, name='result_table'),
    path('uploadstream/<str:user>', job_views.uploadstream, name="uploadstream"),
    path('upload_progress/<str:uuid>', job_views.upload_progress, name="upload_progress"),
    path('cancel_jobs/', job_views.cancel_all_jobs, name="cancel_all_jobs"),
    path('queue/', job_views.get_queue, name="queue"),
    path('jobs/logs/<int:task_id>', job_views.serve_logfile, name="serve_logfile")
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
