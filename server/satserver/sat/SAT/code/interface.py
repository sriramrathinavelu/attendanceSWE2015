from utils import *
from core import *
import os

def training():
	gender = 'M'
	trainUBM(getUBMSourceFolder(gender), gender)
	updateUnlabeledData(getUBMSourceFolder(gender), gender)
	gender = 'F'
	trainUBM(getUBMSourceFolder(gender), gender)
	updateUnlabeledData(getUBMSourceFolder(gender), gender)

def register(fileName, email, gender):
	addTrainingSample(fileName, email, gender)

def testing(fileName, email, gender):
	testFolder = '../data/SPH'
	convertToSPH (fileName, os.path.join(testFolder, email + '.sph'))
	return test(testFolder, email + '.sph', email, getUBMSourceFolder(gender), gender)
