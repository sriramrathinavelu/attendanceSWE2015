import django
django.setup()


from models import *

def addClassRoom(code, name, center, radius):
	try:
		ClassRoom.objects.get(code=code)
	except ClassRoom.DoesNotExist, e:
		room = ClassRoom()
		room.code = code
		room.name = name
		room.center = center
		room.radius = radius
		room.save()

if __name__ == '__main__':
	print "Adding a class.."
	addClassRoom("1", "My-Class", [1,1], 10)
