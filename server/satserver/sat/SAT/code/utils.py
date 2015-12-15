from executors import *
import datetime
import os.path
import random
import os

dateStr = datetime.datetime.now().date().isoformat()
timeStr = datetime.datetime.now().time().isoformat()[:8]

CWD=os.path.dirname(os.path.realpath(__file__))

def getFilesFromFolder(folderName, removeExtension=True):
	walkGen = os.walk(folderName)
	print folderName
	(dirPath, dirNames, fileNames) = walkGen.next() 
	if removeExtension:
		fileNamesWithoutExt = map(lambda x:x.split('.')[0], fileNames)
		return fileNamesWithoutExt
	return fileNames

def getUnlabeledFilesFromFolder(folderName, labelFile):
	walkGen = os.walk(folderName)
	(dirPath, dirNames, fileNames) = walkGen.next() 
	labelFileContents = open(labelFile).read()
	labelFileNames = map(lambda x:x.split(' ')[1], filter(lambda x:x, labelFileContents.split('\n')))
	fileNamesWithoutExt = map(lambda x:x.split('.')[0], fileNames)
	return list(set(fileNamesWithoutExt)-set(labelFileNames))

def prepareInlineDataList(testFile, testDataList):
	testDataListFile = open(testDataList, "w")
	testDataListFile.write(testFile+"\n")
	testDataListFile.close()

def writeListToFile(fileList, outputFile):
	print outputFile
	outputFile = open(outputFile, "w+")
	for fileName in fileList:
		outputFile.write(fileName+"\n")
	outputFile.close()

def writeListTwiceToFile(fileList, outputFile):
	outputFile = open(outputFile, "w")
	for fileName in fileList:
		outputFile.write(fileName+" "+fileName+"\n")
	outputFile.close()

def writeListSplitThriceToFile(fileList, outputFile):
    outputFile = open(outputFile, "w")
    startIndex = 0
    endIndex = 3
    while startIndex < len(fileList):
        fileSubList = fileList[startIndex:endIndex]
        startIndex = endIndex
        endIndex += 3
        if (len(fileSubList) == 3):
            files = " ".join(fileSubList)
            outputFile.write(files+"\n")
        else:
            files = " ".join(fileSubList)
            outputFile.write(files)
            break
    outputFile.close()

def writeIvectorListToFile(fileList, outputFile):
	outputFile = open(outputFile, "w")
	for fileName in fileList:
		outputFile.write(fileName+" "+fileName+"\n")
	outputFile.close()

def getFilesFromDataList(dataList):
	tempFile = open(dataList)
	data = tempFile.read().split()
	tempFile.close()
	return data

def extractMFCC_UBM(dataList, dataExtn, sourceFolder, destFolder):
	fileNames = getFilesFromDataList(dataList)
	for fileName in fileNames:
		extractMFCC(sourceFolder, fileName+"."+dataExtn, destFolder, fileName+"."+"tmp.prm")

def normalizeFeatures_UBM(dataList, sourceFolder, configFile):
	normalizeFeatures(sourceFolder, dataList, configFile)
	

def detectEnergy_UBM(dataList, configFile, sourceFolder, labelFolder):
	detectEnergy(configFile, dataList, sourceFolder, labelFolder)


def normalizeFeatures2_UBM(dataList, configFile, sourceFolder, labelFolder):
	normalizeFeatures2(configFile, dataList, sourceFolder, labelFolder)


def generateConfigFile(templateFile, replacementDict, newFile):
	tFile = open(templateFile, 'r')
	contents = tFile.read()
	newContents = contents%replacementDict
	newFile = open(newFile, "w")
	newFile.write(newContents)
	tFile.close()
	newFile.close()

def prepareNdxFileName(ndxFilename, sampleFilename, speakerName):
	nFile = open(ndxFilename, "w")
	nFile.write(sampleFilename + " " + speakerName + "\n")
	nFile.close()

def prepareNdxIdExtractor(ndxFilename, sampleFilename):
	nFile = open(ndxFilename, "w")
	nFile.write(sampleFilename + " " + sampleFilename + "\n")
	nFile.close()

def getTestingFilePath(folderName, fileName):
	randomStr = str(random.randint(0, 1000))
	newFileName = fileName+timeStr+randomStr
	filePath = '../data/%s/%s/%s'%(folderName, dateStr, newFileName)
	dirName = os.path.dirname(filePath)
	if not os.path.exists(dirName):
		os.makedirs(dirName)
	return filePath

def getLabeledFile(gender):
	return os.path.join(CWD, "../data/NDX/trainModel-%s.ndx"%gender)

def getUnlabeledFile(gender):
	return os.path.join(CWD, "../data/NDX/Plda-%s.ndx"%gender)

def getUBMSourceFolder(gender):
	return os.path.join(CWD, "../data/UBM/SPH/%s/"%gender)

def updateLabeledData(speaker, destFileName, gender):
	# This labeled file has to be updated everytime a user registers
	labeledFile = getLabeledFile(gender)
	with open(labeledFile, "a+") as lFile:
	    lFile.write(speaker + " " + destFileName + "\n")
	return True

def updateUnlabeledData(UBMSourceFolder, gender):
	unlabeledFile = getUnlabeledFile(gender)
	labeledFile = getLabeledFile(gender)
	writeListSplitThriceToFile(getUnlabeledFilesFromFolder(UBMSourceFolder, labeledFile), unlabeledFile)
	return True

def convertToSPH (src, destination):
	if not destination.endswith('.sph'):
		destination = destination + ".sph"
	cmd = "sox %s %s"%(src, destination)
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def addTrainingSample(fileName, speaker, gender):
	ubmSourceFolder = getUBMSourceFolder(gender)
	destFileName = speaker+'train'
	convertToSPH (fileName, os.path.join(ubmSourceFolder, destFileName)+".sph")
	updateLabeledData(speaker, destFileName, gender)

def getScoreFromResult(outputFileName):
	outputFile = open(outputFileName)
	score = outputFile.read().split()[4]
	outputFile.close()
	return score
