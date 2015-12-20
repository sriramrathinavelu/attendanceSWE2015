from rest_framework.parsers import FileUploadParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.http import Http404
from serializers import *
from models import *

import AttenanceRecordManager
import traceback
import datetime
import logging
import os.path
import shutil
import json

from django.core import serializers as djangoSerializers
from mongoengine.queryset import DoesNotExist
from django.core.mail import EmailMessage
from mongoengine.django.auth import User
from django.contrib.auth import login
from django.contrib import messages

from rest_framework import authentication
from rest_framework.authtoken.views import ObtainAuthToken

from sat.SAT.code import interface

logger = logging.getLogger(__name__)

THRESHOLD = 0.5


# Decorators for authentication and authorization purposes

def authenticationRequired(func):
	def func_wrapper(self, request, *args, **kwds):
		if not request.auth:
			return Response("Missing authentication token", status=status.HTTP_401_UNAUTHORIZED)
		return func(self, request, *args, **kwds)
	return func_wrapper
	

def authorizationRequired(func):
	def func_wrapper(self, request, *args, **kwds):
		logger.debug(str(request.user) +  str(request.data))
		if request.user.username != kwds.get('email') and request.user.username != request.POST.get('email') and request.user.username != request.POST.get('professor') and request.user.username != request.data.get('email') and request.user.username != request.data.get('professor'):
			return Response("You do not have sufficient permission", status=status.HTTP_403_FORBIDDEN)
		return func(self, request, *args, **kwds)
	return func_wrapper



def professorRequired(func):
	def func_wrapper(self, request, *args, **kwds):
		try:
			theProf = Professor.objects.get(email=request.user.username)
			if request.POST.get('course_key'):
				course = Course.objects.get(course_key=request.POST.get('course_key'))
				if course.professor != theProf:
					return Response("Professor! you are not incharge of this course", status=status.HTTP_403_FORBIDDEN)
		except:
			return Response("Only a professor can do this", status=status.HTTP_403_FORBIDDEN)
		return func(self, request, *args, **kwds)
	return func_wrapper

def getStudGender(email):
	stud = Student.objects.get(email=email)
	return SATConstants.GENDER_MAP [stud.gender]

def getTrainingFileName(email):
	return fileNameFromEmail(email)+'train'


def fileNameFromEmail(email):
	return email.replace('@','_').replace('.','_')

# Create your views here.

class ObtainMongoAuthToken(ObtainAuthToken):
		
	serializer_class = MongoAuthTokenSerializer

	def post(self, request):
		serializer = self.serializer_class(data=request.data)
		if serializer.is_valid():
			user = serializer.validated_data['user']
			token, created = MongoToken.objects.get_or_create(user=user)
			return Response({'token': token.key}, status=status.HTTP_200_OK)
		else:
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserRegistration(APIView):

	def post(self, request):
		serializer = UserSerializer(data=request.data)
		if serializer.is_valid():
			try:
				user = serializer.save()
				token, created = MongoToken.objects.get_or_create(user=user)
				return Response({'token': token.key}, status=status.HTTP_201_CREATED)
				# return Response("User successfully added", status=status.HTTP_201_CREATED)
			except Exception, e:
				logger.debug (traceback.format_exc())
				logger.debug ("EXP: " + str(e))
				return Response(str(e), status=status.HTTP_400_BAD_REQUEST)
		else:
			logger.debug ("SE: " + str(serializer.errors))
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProfessorCRUD(APIView):

	def get_prof(self, email):
		try:
			return Professor.objects.get(email=email)
		except Professor.DoesNotExist:
			raise Http404
	
	@authenticationRequired
	@authorizationRequired
	def get(self, request, email=None, format=None):
		if not email:
			return Response('Email is required', status=status.HTTP_400_BAD_REQUEST)
		prof = self.get_prof(email)
		serializer = ProfessorSerializer(prof)
		return Response(serializer.data)

	@authenticationRequired
	@authorizationRequired
	def post(self, request, email=None, format=None):
		if email:
			prof = self.get_prof(email=email)
			logger.debug(prof.to_json())
			serializer = ProfessorSerializer(prof, data=request.data)
		else:
			serializer = ProfessorSerializer(data=request.data)
		if serializer.is_valid():
			try:
				prof = serializer.save()
				serializer = ProfessorSerializer(prof)
				return Response(serializer.data, status=status.HTTP_201_CREATED)
			except Exception, e:
				logger.debug (traceback.format_exc())
				logger.debug ("EXP: " + str(e))
				return Response(str(e), status=status.HTTP_400_BAD_REQUEST)
		else:
			logger.debug ("SE: " + str(serializer.errors))
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
	
class ProfessorCourse(APIView):

	def get_prof(self, email):
		try:
			return Professor.objects.get(email=email)
		except Professor.DoesNotExist:
			raise Http404

	@authenticationRequired
	@authorizationRequired
	def get(self, request, email=None, format=None):
		if not email:
			return Response('Email is required', status=status.HTTP_400_BAD_REQUEST)
		prof = self.get_prof(email=email)
		serializedCourses = []
		for course in prof.courses:
			if course.is_weekend:
				serializedCourses.append(WeekEndCourseSerializer(course).data)
			else:
				serializedCourses.append(WeekDayCourseSerializer(course).data)
		return Response(serializedCourses, status=status.HTTP_200_OK)

class StudentCourse(APIView):

	def get_stud(self, email):
		try:
			return Student.objects.get(email=email)
		except Student.DoesNotExist:
			raise Http404

	def get(self, request, email=None, format=None):
		if not email:
			return Response('Email is required', status=status.HTTP_400_BAD_REQUEST)
		stud = self.get_stud(email)
		serializedCourses = []
		for course in stud.courses:
			if course.is_weekend:
				serializedCourses.append(WeekEndCourseSerializer(course).data)
			else:
				serializedCourses.append(WeekDayCourseSerializer(course).data)
		return Response(serializedCourses, status=status.HTTP_200_OK)


class GetCourseType(APIView):

	@authenticationRequired
	def get(self, request, course_key, format=None):
		try:
			course = Course.objects.get(course_key=course_key)
		except Course.DoesNotExist, e:
			return Response("Invalid course key", status=status.HTTP_400_BAD_REQUEST)
		return Response({'courseType' : 'WeekEnd' if course.is_weekend else 'WeekDay'}, status=status.HTTP_200_OK)
			

class GetUserType(APIView):

	@authenticationRequired
	def get(self, request, email, format=None):
		try:
			Professor.objects.get(email=email)
			return Response({'usertype': 'professor'}, status=status.HTTP_200_OK)
		except Professor.DoesNotExist, e:
			try:
				Student.objects.get(email=email)
				return Response({'usertype': 'student'}, status=status.HTTP_200_OK)
			except Student.DoesNotExist, e:
				return Response('Unknown user type', status=status.HTTP_400_BAD_REQUEST)


class GenerateReport(APIView):

	@authenticationRequired
	def get(self, request, email, course_key, format=None):
		try:
			stud = Student.objects.get(email=email)
			course = Course.objects.get(course_key=course_key)
			fileName = AttenanceRecordManager.generateReport(
				course,
				stud,
				course.professor,
				AttenanceRecordManager.getCourseStartDate(course),
				AttenanceRecordManager.getCurrentLocalDateTime()
			)
			emailMsg = EmailMessage(
				subject = 'SAT Report',
				body = 'Please find your requested report as ' +
					   'as attachment',
				to = [email]
			)
			emailMsg.attach (
				'SATreport.csv',
				open(fileName).read(),
				'text/plain'
			)
			emailMsg.send()
			return Response("Done", status=status.HTTP_201_CREATED)
		except Student.DoesNotExist, e:
			return Response("Invalid student", status=status.HTTP_400_BAD_REQUEST)
		except Course.DoesNotExist, e:
			return Response("Invalid Course", status=status.HTTP_400_BAD_REQUEST)
			

class ManualAttendance(APIView):

	@authenticationRequired
	@professorRequired
	def post(self, request):
		try:
			stud = Student.objects.get(email=request.data['email'])
			course = Course.objects.get(course_key=request.data['course_key'])
			dateTime = AttenanceRecordManager.getDateWithTimeZone(request.data['datetime'])
			AttenanceRecordManager.markPresent(stud, course, dateTime)
			return Response("Done", status=status.HTTP_201_CREATED)
		except Student.DoesNotExist, e:
			return Response("Invalid student", status=status.HTTP_400_BAD_REQUEST)
		except Course.DoesNotExist, e:
			return Response("Invalid Course", status=status.HTTP_400_BAD_REQUEST)
		
			
class StudentCRUD(APIView):

	def get_stud(self, email):
		try:
			return Student.objects.get(email=email)
		except Student.DoesNotExist:
			raise Http404
	
	@authenticationRequired
	@authorizationRequired
	def get(self, request, email=None, format=None):
		if not email:
			return Response('Email is required', status=status.HTTP_400_BAD_REQUEST)
		stud = self.get_stud(email)
		serializer = StudentSerializer(stud)
		return Response(serializer.data)

	@authenticationRequired
	@authorizationRequired
	def post(self, request, email=None, format=None):
		if email:
			stud = self.get_stud(email=email)
			serializer = StudentSerializer(stud, data=request.data)
		else:
			serializer = StudentSerializer(data=request.data)
		if serializer.is_valid():
			try:
				stud = serializer.save()
				serializer = StudentSerializer(stud)
				return Response(serializer.data, status=status.HTTP_201_CREATED)
			except Exception, e:
				logger.debug (traceback.format_exc())
				logger.debug ("EXP: " + str(e))
				return Response(str(e), status=status.HTTP_400_BAD_REQUEST)
		else:
			logger.debug ("SE: " + str(serializer.errors))
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ClassRoomGet(APIView):

	@authenticationRequired
	def get(self, request):
	
		def getCodeandName(room):
			return ClassRoomSerializer(room).data 
			#return {
			#	"code":	room.code,
			#	"name": room.name,
			#}

		rooms = ClassRoom.objects.filter()
		listObj = map(getCodeandName, rooms)
		logger.debug (listObj)
		return Response(listObj, status=status.HTTP_200_OK)
		
class CourseGet(APIView):

	@authenticationRequired
	def get(self, request):
	
		def getCourseandName(course):
			return {
				"key"	:	course.course_key,
				"name"	: 	course.course_name,
			}

		courses = Course.objects.filter()
		listObj = map(getCourseandName, courses)
		logger.debug (listObj)
		return Response(listObj, status=status.HTTP_200_OK)

class TheAttendance(APIView):
	parser_classes = (FileUploadParser,)

	@authenticationRequired
	@authorizationRequired
	def put(self, request, email=None, course_key=None, filename=None, format=None):
		try:
			voiceSample = request.FILES['file']
		except KeyError, e:
			return Response("Missing file agrument 'file'", status=status.HTTP_400_BAD_REQUEST)
		if not filename:
			return Response("Missing argument 'filename'", status=status.HTTP_400_BAD_REQUEST)
		if len(filename.split('.')) != 2:
			return Response("Filename having . or missing extension", status=status.HTTP_400_BAD_REQUEST)
		APPDIR = os.path.abspath(os.path.dirname(__file__))
		srcExtn = filename.split('.')[1]
		fileName = os.path.join(APPDIR, 'attendance', fileNameFromEmail(email) + '.' + srcExtn)
		archiveFileName = os.path.join(APPDIR, 'attendance', 'archive', fileNameFromEmail(email) + '-' + datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S') + '.' + srcExtn)
		tempSampleFile = open(fileName, 'w+')
		tempSampleFile.write(voiceSample.read())
		tempSampleFile.close()
		voiceSample.close()
		shutil.copy(fileName, archiveFileName)
		try:
			os.chdir(os.path.join(APPDIR, 'SAT', 'code'))
			score = interface.testing(fileName, fileNameFromEmail(email), getStudGender(email))
			if float(score) > THRESHOLD:
				stud = Student.objects.get(email=email)
				course = Course.objects.get(course_key=course_key)
				dateTime = AttenanceRecordManager.getCurrentLocalDateTime()
				AttenanceRecordManager.markPresent(stud, course, dateTime)
				return Response({"score":score}, status=status.HTTP_202_ACCEPTED)
			else:
				return Response({"score":score}, status=status.HTTP_403_FORBIDDEN)
		except Student.DoesNotExist, e:
			return Response("Student doesn't exist", status=status.HTTP_400_BAD_REQUEST)
		except KeyError, e:
			return Response("Maybe student gender is not configured correctlty", status=status.HTTP_400_BAD_REQUEST)
		except Exception, e:
			return Response(str(e), status=status.HTTP_400_BAD_REQUEST)



class VoiceSampleUpload(APIView):
	parser_classes = (FileUploadParser,)

	@authenticationRequired
	@authorizationRequired
	def put(self, request, email=None, filename=None, format=None):
		logger.debug("Incoming request")
		try:
			voiceSample = request.FILES['file']
		except KeyError, e:
			return Response("Missing file agrument 'file'", status=status.HTTP_400_BAD_REQUEST)
		if not filename:
			return Response("Missing argument 'filename'", status=status.HTTP_400_BAD_REQUEST)
		if len(filename.split('.')) != 2:
			return Response("Filename having . or missing extension", status=status.HTTP_400_BAD_REQUEST)
		APPDIR = os.path.abspath(os.path.dirname(__file__))
		srcExtn = filename.split('.')[1]
		fileName = os.path.join(APPDIR, 'data', getTrainingFileName(email) + '.' + srcExtn)
		if True or not os.path.isfile(fileName):
			tempSampleFile = open(fileName, 'w+')
			tempSampleFile.write(voiceSample.read())
			tempSampleFile.close()
			voiceSample.close()
			try:
				os.chdir(os.path.join(APPDIR, 'SAT', 'code'))
				interface.register(fileName, fileNameFromEmail(email), getStudGender(email))
			except Student.DoesNotExist, e:
				try:
					os.remove(fileName)
				except Exception, e:
					pass
				return Response("Student doesn't exist", status=status.HTTP_400_BAD_REQUEST)
			except KeyError, e:
				try:
					os.remove(fileName)
				except Exception, e:
					pass
				return Response("Improperly configured student gender", status=status.HTTP_400_BAD_REQUEST)
			return Response("File uploaded successfully", status=status.HTTP_202_ACCEPTED)
		return Response("File already present. Contact Administrator to register again", status=status.HTTP_406_NOT_ACCEPTABLE)


class WeekDayCourseCRUD(APIView):

	def get_course(self, course_key):
		try:
			return Course.objects.get(course_key=course_key)
		except Course.DoesNotExist:
			raise Http404
	
	@authenticationRequired
	def get(self, request, course_key=None, format=None):
		if not course_key:
			return Response('Course-key is required', status=status.HTTP_400_BAD_REQUEST)
		course = self.get_course(course_key)
		if course.is_weekend:
			return Response('%s is a weekend course'%course_key, status=status.HTTP_400_BAD_REQUEST)
		serializer = WeekDayCourseSerializer(course)
		return Response(serializer.data)

	@authenticationRequired
	@authorizationRequired
	def post(self, request, course_key=None, format=None):
		if course_key:
			course = self.get_course(course_key=course_key)
			if course.is_weekend:
				return Response('%s is a weekend course'%course_key, status=status.HTTP_400_BAD_REQUEST)
			serializer = WeekDayCourseSerializer(course, data=request.data)
		else:
			serializer = WeekDayCourseSerializer(data=request.data)
		if serializer.is_valid():
			try:
				course = serializer.save()
				serializer = WeekDayCourseSerializer(course)
				return Response(serializer.data, status=status.HTTP_201_CREATED)
			except Exception, e:
				logger.debug ("EXP: " + str(e) + traceback.format_exc())
				return Response(str(e), status=status.HTTP_400_BAD_REQUEST)
		else:
			logger.debug ("SE: " + str(serializer.errors))
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class WeekEndCourseCRUD(APIView):

	def get_course(self, course_key):
		try:
			return Course.objects.get(course_key=course_key)
		except Course.DoesNotExist:
			raise Http404
	
	@authenticationRequired
	def get(self, request, course_key=None, format=None):
		if not course_key:
			return Response('Course-key is required', status=status.HTTP_400_BAD_REQUEST)
		course = self.get_course(course_key)
		if not course.is_weekend:
			return Response('%s is a weekday course'%course_key, status=status.HTTP_400_BAD_REQUEST)
		serializer = WeekEndCourseSerializer(course)
		return Response(serializer.data)

	@authenticationRequired
	def post(self, request, course_key=None, format=None):
		if course_key:
			course = self.get_course(course_key=course_key)
			if not course.is_weekend:
				return Response('%s is a weekday course'%course_key, status=status.HTTP_400_BAD_REQUEST)
			serializer = WeekEndCourseSerializer(course, data=request.data)
		else:
			serializer = WeekEndCourseSerializer(data=request.data)
			logger.debug(str(request.data))
		if serializer.is_valid():
			try:
				course = serializer.save()
				serializer = WeekEndCourseSerializer(course)
				return Response(serializer.data, status=status.HTTP_201_CREATED)
			except Exception, e:
				logger.debug ("EXP: " + str(e) + traceback.format_exc())
				return Response(str(e), status=status.HTTP_400_BAD_REQUEST)
		else:
			logger.debug ("SE: " + str(serializer.errors))
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


