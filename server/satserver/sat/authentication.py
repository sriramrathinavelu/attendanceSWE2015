from rest_framework.authentication import TokenAuthentication
from rest_framework import exceptions
from models import MongoToken


class MongoAuthentication(TokenAuthentication):
	
	model = MongoToken

	def authenticate_credentials(self, key):
		try:
			token = self.model.objects.get(key=key.decode('UTF-8'))
		except self.model.DoesNotExist:
			raise exceptions.AuthenticationFailed ('Invalid Token')

		if not token.user.is_active:
			raise exceptions.AuthenticationFailed ('User Inactive or Deleted')

		return (token.user, token)
