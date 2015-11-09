import django
django.setup()

from collections import OrderedDict
from models import *
import datetime
import logging
import pytz
import csv

logger = logging.getLogger(__name__)

TIMEZONE = 'US/Pacific'

def getProfessorName(obj):
	return obj.first_name + " " + obj.last_name

def getStudentName(obj):
	return obj.first_name + " " + obj.last_name

def getCourseName(obj):
	return obj.course_name

def getCourseKey(obj):
	return obj.course_key

def getCheckinTime(obj):
	return obj.checkin_time.replace(tzinfo=pytz.utc).astimezone(pytz.timezone(TIMEZONE))

def getCheckinStatus(obj):
	return "PRESENT" if obj.checkin_status == SATConstants.PRESENT else "ABSENT"

REPORT_COLUMNS = OrderedDict()

REPORT_COLUMNS["Professor"]		=	getProfessorName
REPORT_COLUMNS["Student"]		=	getStudentName
REPORT_COLUMNS["Course"]		=	getCourseName
REPORT_COLUMNS["Key"]			=	getCourseKey
REPORT_COLUMNS["Time"]			=	getCheckinTime
REPORT_COLUMNS["Status"]		=	getCheckinStatus

"""
ALGO:

Get the current date.
Get all the classes for the date
Fill up the attendance for each student in each of the class.
"""

def getCurrentLocalDateTime():
	curDateTime = datetime.datetime.utcnow().replace(tzinfo=pytz.utc)
	curDateTime = curDateTime.astimezone(pytz.timezone(TIMEZONE))
	return curDateTime + datetime.timedelta(days=0)

def getCurrentDay(curDate):
	return 1 # curDate.weekday()

def getWeekDayCourses(weekDay):
	return Course.objects.filter(day_of_week = weekDay)

def getStudentsByCourse(course):
	return Student.objects.filter(courses=course)


def __getRecords(course, student, startDate, endDate):
	try:
		records = AttendanceRecord.objects.filter(
			student=student,
			course=course,
			checkin_time__gt=startDate,
			checkin_time__lt=endDate
		)
		return records
	except DoesNotExist, e:
		return None


def __getRecord(student, course, curDateTime):
	try:
		today = datetime.datetime(curDateTime.year, curDateTime.month, curDateTime.day,
			0, 0, 0).replace(tzinfo=pytz.timezone(TIMEZONE))
		tomorrow = today + datetime.timedelta(days=1)
		record = AttendanceRecord.objects.get(
			student=student,
			course=course,
			checkin_time__gt=today,
			checkin_time__lt=tomorrow
		)
		return record
	except DoesNotExist, e:
		return None



def setupAttendanceRecord(student, course, curDateTime):
	if not __getRecord(student, course, curDateTime):
		record = AttendanceRecord()
		record.student = student
		record.course = course
		record.professor = Professor.objects.get(email=course.professor.id)
		record.checkin_time = curDateTime
		record.checkin_status = SATConstants.ABSENT
		record.save()
		print record

def markPresent(student, course, curDateTime):
	record =  __getRecord(student, course, curDateTime)
	if not record:
		logger.warn ("Record did not exist when marking attendance")
		record = AttendanceRecord()
		record.student = student
		record.course = course
		record.professor = Professor.objects.get(email=course.professor.id)
	record.checkin_time = curDateTime
	record.checkin_status = SATConstants.PRESENT
	record.save()


def getReportFileName(course, startDate, endDate):
	return course.course_key + "-" + startDate.strftime("%Y-%m-%d") + "-" + endDate.strftime("%Y-%m-%d")

def generateReport(course, student, professor, startDate, endDate):
	records = __getRecords(course, student, startDate, endDate)
	with open(getReportFileName(course, startDate, endDate), 'wb') as csvFile:
		FieldNames = REPORT_COLUMNS.keys()
		writer = csv.DictWriter(csvFile, fieldnames=FieldNames, dialect=csv.excel_tab)
		writer.writeheader()
		for record in records:
			writer.writerow({
				'Professor'	:	REPORT_COLUMNS['Professor'](professor),
				'Student'	:	REPORT_COLUMNS['Student'](student),
				'Course'	:	REPORT_COLUMNS['Course'](course),
				'Key'		:	REPORT_COLUMNS['Key'](course),
				'Time'		:	REPORT_COLUMNS['Time'](record),
				'Status'	:	REPORT_COLUMNS['Status'](record),
			})



def start():
	# Getting the current date 
	curDateTime = getCurrentLocalDateTime()
	print curDateTime
	curDay = getCurrentDay(curDateTime)
	print curDay
	courses = getWeekDayCourses(curDay)
	print courses
	for course in courses:
		students = getStudentsByCourse(course)
		for student in students:
			print student, course
			setupAttendanceRecord(student, course, curDateTime)
			markPresent(student, course, curDateTime)
	
	stud = Student.objects.get(email='student1@itu.edu')
	course = Course.objects.get(course_key='swe500-2')
	professor = course.professor
	startDate = datetime.datetime.strptime("2015-11-01T0:0:0", '%Y-%m-%dT%H:%M:%S').replace(tzinfo=pytz.timezone(TIMEZONE))
	endDate = datetime.datetime.strptime("2015-11-02T0:0:0", '%Y-%m-%dT%H:%M:%S').replace(tzinfo=pytz.timezone(TIMEZONE))
	print startDate, endDate
	generateReport(course, stud, professor, startDate, endDate)


start()
