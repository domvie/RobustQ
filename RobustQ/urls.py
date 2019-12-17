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
from jobs.models import Job
from django.contrib.auth.models import User
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import url
from rest_framework import routers, serializers, viewsets


# Serializers define the API representation.
class JobSerializer(serializers.HyperlinkedModelSerializer):
    # url = serializers.HyperlinkedIdentityField(view_name="jobs:details")

    class Meta:
        model = Job
        fields = '__all__'  # ['url', 'username', 'email', 'is_staff']


class UserSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = User
        fields = ['url', 'username', 'email', 'is_staff']


class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

# ViewSets define the view behavior.
class JobViewSet(viewsets.ModelViewSet):
    user = UserSerializer()
    queryset = Job.objects.all()
    serializer_class = JobSerializer

# Routers provide an easy way of automatically determining the URL conf.
router = routers.DefaultRouter()
router.register(r'jobs', JobViewSet)
router.register(r'users', UserViewSet)



urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('index.urls')),
    path('register/', user_views.register, name='register'),
    path('login/', auth_views.LoginView.as_view(template_name='users/login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(template_name='users/logout.html'), name='logout'),
    path('jobs/', job_views.JobOverView.as_view(), name='jobs'),
    path('profile/', user_views.profile, name='profile'),
    path('jobs/new/', job_views.NewJobView.as_view(), name='new'),
    path('jobs/details/<int:pk>', job_views.JobDetailView.as_view(), name='details'),
    path('jobs/delete/<int:pk>', job_views.JobDeleteView.as_view(), name='job-delete'),
    # url(r'^api/', include(router.urls)),
    # url(r'^api-auth/', include('rest_framework.urls', namespace='api'))
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
