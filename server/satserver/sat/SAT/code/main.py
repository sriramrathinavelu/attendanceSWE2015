from utils import *
from core import *

gender = 'M'
trainUBM(getUBMSourceFolder(gender), gender)
gender = 'F'
#trainUBM(getUBMSourceFolder(gender), gender)

#tFile = open('../tmp/sriram.sph', 'r')
#addTrainingSample(tFile, 'sriram', 'M')
#tFile.close()

gender = 'M'
updateUnlabeledData(getUBMSourceFolder(gender), gender)


testFolder = '../data/SPH'
testFile = 'sriramTest.sph'
speaker = 'sriram'
gender = 'M'

#test(testFolder, testFile, speaker, getUBMSourceFolder(gender), gender) 

from interface import *

#training()
