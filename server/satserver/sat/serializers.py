from django.contrib.auth import authenticate
from mongoengine.django.auth import User
from rest_framework import serializers
from models import *
import datetime
import logging

logger = logging.getLogger(__name__)

class MongoAuthTokenSerializer(serializers.Serializer):
	email = serializers.CharField(required=True)
	password = serializers.CharField(required=True)
	
	def validate(self, attrs):
		username = attrs.get('email')
		password = attrs.get('password')
		if username and password:
			try:
				user = User.objects.get(username=username)
			except User.DoesNotExist, e:
				raise serializers.ValidationError("Unknown user " + username)
			user.backend = 'mongoengine.django.auth.MongoEngineBackend'
			user = authenticate(username=username, password=password)
			if user:
				if not user.is_active:
					msg = 'User account is disabled.'
					raise serializers.ValidationError(msg)
			else:
				msg = 'Unable to log in with provided credentials.'
				raise serializers.ValidationError(msg)
		else:
			msg = 'Must include "username" and "password".'
			raise serializers.ValidationError(msg)
		
		attrs['user'] = user
		return attrs

def inplaceUpdate(excl_attrs, instance, validated_data):
	for attr in validated_data:
		if attr not in excl_attrs:
			setattr(instance, attr, validated_data[attr])
	return instance
	
class UserSerializer(serializers.Serializer):
	email = serializers.EmailField(write_only=True, required=True)
	password = serializers.CharField(write_only=True, required=True)

	def create(self, validated_data):
		try:
			instance = User.objects.create(username=validated_data['email'])
		except NotUniqueError, e:
			raise Exception("User is already registered.")
		return self.update(instance, validated_data)

	def update(self, instance, validated_data):
		user = User.objects.get(username=validated_data['email'])
		user.set_password(validated_data['password'])
		user.save()
		return user;

class ProfessorSerializer(serializers.Serializer):
	email = serializers.EmailField(required=False)
	first_name = serializers.CharField(required=False)
	last_name = serializers.CharField(required=False)
	imei_no = serializers.CharField(write_only=True, required=False)
	courses = serializers.ListField(read_only=True, child=serializers.CharField())

	def update(self, instance, validated_data):
		for k, v in validated_data.iteritems():
			setattr(instance, k, v)
		try:
			instance.save()
		except NotUniqueError, e:
			raise Exception("User is already registered as a Professor")
		return instance
	
	def create(self, validated_data):
		instance = Professor()
		return self.update(instance, validated_data)

class StudentSerializer(serializers.Serializer):
	email = serializers.EmailField(required=False)
	first_name = serializers.CharField(required=False)
	last_name = serializers.CharField(required=False)
	gender = serializers.IntegerField(required=False)
	imei_no = serializers.CharField(write_only=True, required=False)
	courses = serializers.ListField(child=serializers.CharField())

	def update(self, instance, validated_data):
		excl_attrs = ['courses']
		instance = inplaceUpdate(excl_attrs, instance, validated_data)
		_courses = []
		logger.debug(validated_data)
		if 'courses' in validated_data:
			try:
				for c in validated_data['courses']:
					_courses.append(Course.objects.get(
										course_key=c
					))
			except Course.DoesNotExist, e:
				raise Exception("Invalid course")
			instance.courses = _courses
		try:
			logger.debug(instance.to_json())
			instance.save()
		except NotUniqueError, e:
			logger.debug(str(e))
			raise Exception("User is already registered as a student")
		return instance

	def create(self, validated_data):
		instance = Student()
		return self.update(instance, validated_data)

class ClassRoomSerializer(serializers.Serializer):
	code = serializers.CharField(required=False)
	name = serializers.CharField(required=False)
	center = serializers.DictField(required=False)
	radius = serializers.IntegerField(required=False)

class GenericCourseSerializer(serializers.Serializer):
	course_key = serializers.CharField(read_only=True,required=False)
	course_name = serializers.CharField(required=False)
	course_code = serializers.CharField(required=False)
	course_section = serializers.CharField(required=False)
	class_room = serializers.CharField(required=False)
	duration_start = serializers.DateTimeField(input_formats=['%Y-%m-%dT%H:%M:%S'], required=False)
	duration_end = serializers.DateTimeField(input_formats=['%Y-%m-%dT%H:%M:%S'], required=False)
	time_start = serializers.DateTimeField(input_formats=['%Y-%m-%dT%H:%M:%S'], required=False)
	time_end = serializers.DateTimeField(input_formats=['%Y-%m-%dT%H:%M:%S'], required=False)
	trimester = serializers.CharField(required=False)
	professor = serializers.CharField(required=False)


	def update(self, instance, validated_data):
		excl_attrs = ['class_room', 'professor']
		instance = inplaceUpdate(excl_attrs, instance, validated_data)
		if 'course_code' in validated_data and 'course_section' in validated_data:
			instance.course_key = validated_data['course_code']+'-'+validated_data['course_section']
		if 'class_room' in validated_data:
			try:
				class_room_obj = ClassRoom.objects.get(
						code=validated_data['class_room']
				)
			except ClassRoom.DoesNotExist, e:
				raise Exception("Invalid Class Room")
			instance.class_room = class_room_obj
		if 'professor' in validated_data:
			try:
				professor_obj = Professor.objects.get(
						email=validated_data['professor']
				)
			except Professor.DoesNotExist, e:
				raise Exception("Invalid professor email")
			instance.professor = professor_obj
		return instance

	def create(self, validated_data):
		instance = Course()
		return self.update(instance, validated_data)


class WeekDayCourseSerializer(GenericCourseSerializer):
	day_of_week = serializers.IntegerField(required=False, max_value=4, min_value=0)

	def update(self, instance, validated_data):
		instance = super(WeekDayCourseSerializer, self).update(instance, validated_data)
		instance.is_weekend = False
		if 'day_of_week' in validated_data:
			instance.day_of_week = validated_data['day_of_week']
		logger.debug (instance.to_json())
		instance.save()
		return instance

	def create(self, validated_data):
		instance = super(WeekDayCourseSerializer, self).create(validated_data)
		return self.update(instance, validated_data)

class WeekEndCourseSerializer(GenericCourseSerializer):
	specific_dates = serializers.ListField(child=serializers.DateTimeField(input_formats=['%Y-%m-%dT%H:%M:%S']))

	def update(self, instance, validated_data):
		instance = super(WeekEndCourseSerializer, self).update(instance, validated_data)
		instance.is_weekend = True
		logger.debug (validated_data)
		if 'specific_dates' in validated_data:
			instance.specific_dates = validated_data['specific_dates']
		instance.save()
		return instance

	def create(self, validated_data):
		instance = super(WeekEndCourseSerializer, self).create(validated_data)
		return self.update(instance, validated_data)
