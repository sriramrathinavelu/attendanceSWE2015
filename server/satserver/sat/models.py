from mongoengine.django.auth import User
from django.utils.timezone import now
from django.db import models
from mongoengine import *
import datetime
import binascii
import logging
import os
# Create your models here.

logger = logging.getLogger(__name__)

class SATConstants:
	PRESENT = 1
	ABSENT = 2
	MALE = 1		# Hope making MALE 1 doesn't make me a sexist
	FEMALE = 2
	GENDER_MAP = {MALE:'M', FEMALE:'F'}


# TODO: Should I have both required=True and null=False or are they redundant?

class MongoToken(Document):
	key = StringField(max_length=44, required=True, null=False)
	user = ReferenceField('User', required=True, null=False)
	created = DateTimeField(required=True, null=False)

	def __init__(self, *args, **values):
		super(MongoToken, self).__init__(*args, **values)
		if not self.key:
			self.key = self.generate_key()

	def save(self, *args, **kwargs):
		if not self.id:
			self.created = now()
		return super(MongoToken, self).save(*args, **kwargs)
	
	def generate_key(self):
		return binascii.hexlify(os.urandom(22)).decode()

	def __unicode__(self):
		return self.key

class Professor(Document):
	email = EmailField(required=True, unique=True, null=False, primary_key=True)
	first_name = StringField(required=True, null=False)
	last_name = StringField(required=True, null=False)
	courses = ListField(ReferenceField('Course'))
	imei_no = StringField()
	ctime = DateTimeField(default=now)
	mtime = DateTimeField(default=now)

	def __str__(self):
		return self.email

	def save(self, *args, **kwds):
		self.mtime = now()
		return super(Professor, self).save(*args, **kwds)

	def hasCourse(self, courseKey):
		for course in self.courses:
			if course.course_key == courseKey:
				return True
		return False

	def addCourse(self, newCourse):
		if not self.hasCourse(newCourse.course_key):
			self.courses.append(newCourse)
			return super(Professor, self).save()


class ClassRoom(Document):
	code = StringField(required=True, unique=True, null=False, primary_key=True)
	name = StringField(required=True, null=False)
	center = PointField(required=True, null=False)
	radius = IntField(required=True, null=False)

	def __str__(self):
		return self.code

class Course (Document):
	course_key = StringField(required=True, null=False, unique=True, primary_key=True)
	course_name = StringField(required=True, null=False)
	course_code = StringField(required=True, null=False)
	course_section = StringField(required=True, null=False)
	class_room = ReferenceField('ClassRoom', required=True, null=False)
	duration_start = DateTimeField(required=True, null=False)
	duration_end = DateTimeField(required=True, null=False)
	time_start = DateTimeField(required=True, null=False)
	time_end = DateTimeField(required=True, null=False)
	is_weekend = BooleanField(required=True, null=False, default=False)
	day_of_week = IntField()
	specific_dates = ListField(DateTimeField())
	trimester = StringField(required=True, null=False)
	professor = ReferenceField('Professor', required=True, null=False)

	def __str__(self):
		return self.course_key

	def save(self, *args, **kwds):
		thisCourse = super(Course, self).save(*args, **kwds)
		if self.professor: 
			self.professor.addCourse(thisCourse)
		return thisCourse

class Student(Document):
	email = EmailField(required=True, unique=True, null=False,primary_key=True)
	first_name = StringField(required=True, null=False)
	last_name = StringField(required=True, null=False)
	gender = IntField(required=True, null=False)
	imei_no = StringField()
	voice_Sample = StringField() # File with voice sample
	ctime = DateTimeField(default=now)
	mtime = DateTimeField(default=now)
	courses = ListField(ReferenceField('Course'))

	def save(self, *args, **kwds):
		self.mtime = now()
		return super(Student, self).save(*args, **kwds)

	def __str__(self):
		return self.email

class AttendanceRecord(Document):
	professor = ReferenceField('Professor')
	student = ReferenceField('Student')
	course = ReferenceField('Course')
	date = DateTimeField(null=False)
	checkin_time = DateTimeField(null=True)
	checkin_status = IntField(null=False)
	voice_auth = StringField(null=True) # File with authenticating voice segment

	def __str__(self):
		return '"' + str(self.student) + '"-"' + str(self.course) + '"@"' + str(self.checkin_time) + '":"' + str(self.checkin_status) + '"'

Course.register_delete_rule(ClassRoom, 'Course', NULLIFY)
Course.register_delete_rule(Professor, 'Course', NULLIFY)
Student.register_delete_rule(Course, 'Student', NULLIFY)
AttendanceRecord.register_delete_rule(Professor, 'AttendanceRecord', NULLIFY)
AttendanceRecord.register_delete_rule(Student, 'AttendanceRecord', NULLIFY)
AttendanceRecord.register_delete_rule(Course, 'AttendanceRecord', NULLIFY)
