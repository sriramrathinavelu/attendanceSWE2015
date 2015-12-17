import django
django.setup()


from sat.models import *
import datetime
import requests
import logging
import json
import sys

import ClassRoomManager

import httplib
httplib.HTTPConnection.debuglevel = 0 

logging.basicConfig() # you need to initialize logging, otherwise you will not see anything from requests
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

BASEURL = "http://localhost:8000/"
HEADERS = {
	'Content-Type'	:	'application/json'
}


professorEmail = 'qtprof@itu.edu'
professorPassword = 'password'
professorToken = None

studentEmail = 'sriramrathinavelu@itu.edu'
studentPassword = 'password'
studentToken = None

professorFirstName = 'firstName'
professorLastName = 'lastName'
studentFirstName = 'studFirst'
studentLastName = 'studLast'
studentGender = 1
studentCourses = []
studentToken = None

studentVoiceSampleFile = 'sample.sph'

professorObj = None
studentObj = None

classRoomName = 'qtclass'
classRoomCode = 'class-1'
classRoomCenter = [0, 0]
classRoomRadius = 100


weekdayCourseName = 'qtCourse-1'
weekdayCourseCode = '700'
weekdayCourseSection = '1'
weekdayCourseClassRoom = classRoomCode
weekdayCourseDurationStart = "2015-12-01T0:0:0"
weekdayCourseDurationEnd = "2016-01-04T0:0:0"
weekdayCourseTimeStart = "2016-01-04T18:00:00"
weekdayCourseTimeEnd = "2016-01-04T20:00:00"
weekdayCourseTrimester = 'Falls 2015'
weekdayCourseDayOfWeek = 3 #Thursday
weekdayCourseProfessor = professorEmail

weekendCourseName = 'qtCourse-2'
weekendCourseCode = '800'
weekendCourseSection = '1'
weekendCourseClassRoom = classRoomCode
weekendCourseDurationStart = "2015-12-01T0:0:0"
weekendCourseDurationEnd = "2016-01-04T0:0:0"
weekendCourseTimeStart = "2016-01-04T18:00:00"
weekendCourseTimeEnd = "2016-01-04T20:00:00"
weekendCourseTrimester = 'Falls 2015'
weekendCourseSpecificDates = [
	"2015-12-05T0:0:0",
	"2015-12-17T0:0:0",
	"2015-12-19T0:0:0",
	"2015-12-20T0:0:0",
	"2016-01-02T0:0:0",
	"2016-01-03T0:0:0"
]
weekendCourseProfessor = professorEmail


print >> sys.stderr, "Checking if", professorEmail, "exists" 

try:
	user = User.objects.get(username=professorEmail)
	print >> sys.stderr, "Deleting", professorEmail
#	try:
#		prof = Professor.objects.get(email=professorEmail)
#		profCourses = Course.objects.filter(professor=prof)
#		for course in profCourses:
#			students = Students.objects.filter(courses=course)
#			for stud in students:
#				stud.delete()
#			course.delete()
#		prof.delete()
#		print >> sys.stderr, "Deleting professor, his courses and students in his course"
#	except Professor.DoesNotExist:
#		print >> sys.stderr, "Professor does not exist"
#		pass
	user.delete()
except User.DoesNotExist:
	print >> sys.stderr, professorEmail, "doesn't exist"
	pass

# Registering a user

print >> sys.stderr, "Trying to register", professorEmail

postData = json.dumps({
	'email'		:	professorEmail,
	'password'	:	professorPassword
}) 

resp = requests.post (BASEURL+'register/', headers=HEADERS, data=postData)

print >> sys.stderr, "Got reponse with status", str(resp.status_code)

if resp.status_code == 201:
	print >> sys.stderr, "Registration succesful"
	tokenResponse = json.loads(resp.text)
	professorToken = tokenResponse['token'] 
else:
	print >> sys.stderr, "Registration Failed"
	print json.loads(resp.text)
	sys.exit(1)

# Adding a Professor

postData = json.dumps({
	'email'			:	professorEmail,
	'first_name'	:	professorFirstName,
	'last_name'		:	professorLastName,
})

HEADERS['Authorization'] = 'Token ' + professorToken

resp = requests.post (BASEURL+'professor/', headers=HEADERS, data=postData)

if resp.status_code == 201:
	print >> sys.stderr, "Professor succesfully created"
	professorObj = Professor.objects.get(email=professorEmail)
else:
	print >> sys.stderr, "Professor creation failed"
	sys.exit(1)

# Adding a Class Room

print >> sys.stderr, "Adding a classroom"

ClassRoomManager.addClassRoom(
	classRoomCode,
	classRoomName,
	classRoomCenter,
	classRoomRadius
)

# Adding a weekday course

postData = json.dumps({
	'course_name'		:		weekdayCourseName,
	'course_code'		:		weekdayCourseCode,
	'course_section'	:		weekdayCourseSection,
	'class_room'		:		weekdayCourseClassRoom,
	'duration_start'	:		weekdayCourseDurationStart,
	'duration_end'		:		weekdayCourseDurationEnd,
	'time_start'		:		weekdayCourseTimeStart,
	'time_end'			:		weekdayCourseTimeEnd,
	'trimester'			:		weekdayCourseTrimester,
	'professor'			:		weekdayCourseProfessor,
	'day_of_week'		:		weekdayCourseDayOfWeek,	
})

resp = requests.post (BASEURL+'weekdaycourse/', headers=HEADERS, data=postData)
print >> sys.stderr, "Got reponse with status", str(resp.status_code)
if resp.status_code == 201:
	print >> sys.stderr, "Weekday course created"
else:
	print >> sys.stderr, "Failed to create weekday course"
	sys.exit(1)


postData = json.dumps({
	'course_name'		:		weekendCourseName,
	'course_code'		:		weekendCourseCode,
	'course_section'	:		weekendCourseSection,
	'class_room'		:		weekendCourseClassRoom,
	'duration_start'	:		weekendCourseDurationStart,
	'duration_end'		:		weekendCourseDurationEnd,
	'time_start'		:		weekendCourseTimeStart,
	'time_end'			:		weekendCourseTimeEnd,
	'trimester'			:		weekendCourseTrimester,
	'professor'			:		weekendCourseProfessor,
	'specific_dates'	:		weekendCourseSpecificDates,
})

resp = requests.post (BASEURL+'weekendcourse/', headers=HEADERS, data=postData)
print >> sys.stderr, "Got reponse with status", str(resp.status_code)
if resp.status_code == 201:
	print >> sys.stderr, "weekend course created"
else:
	print >> sys.stderr, "Failed to create weekend course"
	sys.exit(1)

try:
	user = User.objects.get(username=studentEmail)
	print >> sys.stderr, "Deleting", studentEmail
	user.delete()
except User.DoesNotExist:
	print >> sys.stderr, studentEmail, "doesn't exist"
	pass

# Registering the student
postData = json.dumps({
	'email'		:	studentEmail,
	'password'	:	studentPassword
}) 

HEADERS.pop('Authorization')

resp = requests.post (BASEURL+'register/', headers=HEADERS, data=postData)

print >> sys.stderr, "Got reponse with status", str(resp.status_code)

if resp.status_code == 201:
	print >> sys.stderr, "Student Registration succesful"
	tokenResponse = json.loads(resp.text)
	studentToken = tokenResponse['token'] 
else:
	print >> sys.stderr, "Student Registration Failed"
	print json.loads(resp.text)
	sys.exit(1)

postData = json.dumps({
	'email'			:	studentEmail,
	'first_name'	:	studentFirstName,
	'last_name'		:	studentLastName,
	'gender'		:	studentGender,
	'courses'		:	[]
})

HEADERS['Authorization'] = 'Token ' + studentToken

resp = requests.post (BASEURL+'student/', headers=HEADERS, data=postData)

if resp.status_code == 201:
	print >> sys.stderr, "Student succesfully created"
	#studentObj = Student.objects.get(email=studentEmail)
else:
	print >> sys.stderr, "Student creation failed"
	sys.exit(1)

# Adding Courses
postData = json.dumps({
	'email'		:	studentEmail,
	'courses'	:	[weekdayCourseCode+'-'+weekdayCourseSection]
})

resp = requests.post (BASEURL+'student/'+studentEmail+'/', headers=HEADERS, data=postData)

if resp.status_code == 201:
	print >> sys.stderr, "Student succesfully created"
	#studentObj = Student.objects.get(email=studentEmail)
else:
	print >> sys.stderr, "Student creation failed"
	sys.exit(1)

# Adding Courses
postData = json.dumps({
	'email'		:	studentEmail,
	'courses'	:	[
						weekdayCourseCode+'-'+weekdayCourseSection,
						weekendCourseCode+'-'+weekendCourseSection
	]
})

resp = requests.post (BASEURL+'student/'+studentEmail+'/', headers=HEADERS, data=postData)

if resp.status_code == 201:
	print >> sys.stderr, "Student succesfully created"
	#studentObj = Student.objects.get(email=studentEmail)
else:
	print >> sys.stderr, "Student creation failed"
	sys.exit(1)

# Voice Sample Registration
fileData = {
	'file'	:	open(studentVoiceSampleFile, 'rb')
}

HEADERS['Authorization'] = 'Token ' + studentToken

resp = requests.put (BASEURL+'voice/'+studentEmail+'/'+studentVoiceSampleFile+'/', headers=HEADERS, data=fileData)

print resp.status_code


