from django.conf.urls import url
from rest_framework.urlpatterns import format_suffix_patterns
from views import *

urlpatterns = [
	url(r'^register/$', UserRegistration.as_view()),
	url(r'^login/$', ObtainMongoAuthToken.as_view()),
    url(r'^professor/$', ProfessorCRUD.as_view()),
    url(r'^professor/(?P<email>[^@]+@[^@]+\.[^@]+)/$', ProfessorCRUD.as_view()),
    url(r'^student/$', StudentCRUD.as_view()),
    url(r'^student/(?P<email>[^@]+@[^@]+\.[^@]+)/$', StudentCRUD.as_view()),
	url(r'^voice/(?P<email>[^@]+@[^@]+\.[^@]+)/(?P<filename>\w+\.?\w*)/$', VoiceSampleUpload.as_view()),
	url(r'^classrooms/$', ClassRoomGet.as_view()),
    url(r'^weekdaycourse/$', WeekDayCourseCRUD.as_view()),
    url(r'^weekdaycourse/(?P<course_key>[a-z0-9]+-\d+)/$', WeekDayCourseCRUD.as_view()),
    url(r'^weekendcourse/$', WeekEndCourseCRUD.as_view()),
    url(r'^weekendcourse/(?P<course_key>[a-z0-9]+-\d+)/$', WeekEndCourseCRUD.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
