from rest_framework.parsers import FileUploadParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.http import Http404
from serializers import *
from models import *
import traceback
import logging
import os.path
import json

from django.contrib.auth import login
from mongoengine.django.auth import User
from mongoengine.queryset import DoesNotExist
from django.contrib import messages

from rest_framework import authentication

from rest_framework.authtoken.views import ObtainAuthToken

logger = logging.getLogger(__name__)

# Decorators for authentication and authorization purposes

def authenticationRequired(func):
	def func_wrapper(self, request, *args, **kwds):
		if not request.auth:
			return Response("Missing authentication token", status=status.HTTP_401_UNAUTHORIZED)
		return func(self, request, *args, **kwds)
	return func_wrapper
	

def authorizationRequired(func):
	def func_wrapper(self, request, *args, **kwds):
		if request.user.username != kwds.get('email') and request.user.username != request.POST.get('email') and request.user.username != request.POST.get('professor'):
			return Response("You do not have sufficient permission", status=status.HTTP_403_FORBIDDEN)
		return func(self, request, *args, **kwds)
	return func_wrapper
		

# Create your views here.

class ObtainMongoAuthToken(ObtainAuthToken):
		
	serializer_class = MongoAuthTokenSerializer

	def post(self, request):
		serializer = self.serializer_class(data=request.data)
		if serializer.is_valid():
			user = serializer.validated_data['user']
			token, created = MongoToken.objects.get_or_create(user=user)
			return Response({'token': token.key})
		else:
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserRegistration(APIView):

	def post(self, request):
		serializer = UserSerializer(data=request.data)
		if serializer.is_valid():
			try:
				user = serializer.save()
				return Response("User successfully added", status=status.HTTP_201_CREATED)
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
			return {
				"code":	room.code,
				"name": room.name,
			}

		rooms = ClassRoom.objects.filter()
		listObj = map(getCodeandName, rooms)
		logger.debug (listObj)
		return Response(listObj, status=status.HTTP_200_OK)
		

class VoiceSampleUpload(APIView):
	parser_classes = (FileUploadParser,)

	@authenticationRequired
	@authorizationRequired
	def put(self, request, email=None, filename=None, format=None):
		try:
			voiceSample = request.FILES['file']
		except KeyError, e:
			return Response("Missing file agrument 'file'", status=status.HTTP_400_BAD_REQUEST)
		APPDIR = os.path.abspath(os.path.dirname(__file__))
		fileName = os.path.join(APPDIR, 'data', email) 
		if not os.path.isfile(fileName):
			tempSampleFile = open(fileName, 'w+')
			tempSampleFile.write(voiceSample.read())
			tempSampleFile.close()
			voiceSample.close()
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


