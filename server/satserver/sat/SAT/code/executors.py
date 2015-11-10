import subprocess
import os.path
import shlex
import os

CWD=os.path.dirname(os.path.realpath(__file__))

def extractMFCC(sourceFolder, sourceFile, destFolder, destFile):
	cmd = "../bin/sfbcep -m -k 0.97 -p19 -n 24 -r 22 -e -D -A -F SPHERE %s %s"%(os.path.join(sourceFolder, sourceFile), os.path.join(destFolder, destFile))
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)


def normalizeFeatures(sourceFolder, sourceFile, configFile):
	cmd = "../bin/NormFeat --config %s --inputFeatureFilename %s --featureFilesPath %s"%(configFile, sourceFile, sourceFolder)
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)


def detectEnergy(configFile, sourceFile, sourceFolder, labelFolder):
	cmd = "../bin/EnergyDetector  --config %s --inputFeatureFilename %s --featureFilesPath  %s  --labelFilesPath %s"%(configFile, sourceFile, sourceFolder, labelFolder)
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def normalizeFeatures2(configFile, sourceFile, sourceFolder, labelFolder):
	cmd = "../bin/NormFeat --config %s --inputFeatureFilename %s --featureFilesPath %s --labelFilesPath %s"%(configFile, sourceFile, sourceFolder, labelFolder)
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def trainWorld_UBM(configFile):
	cmd = "../bin/TrainWorld --config %s"%configFile
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def totalVariabilityMatrix_UBM(configFile):
	cmd = "../bin/TotalVariability --config %s"%configFile
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def extractIVectors(configFile):
	cmd = "../bin/IvExtractor --config %s"%configFile
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

def testIVectors(configFile):
	cmd = "../bin/IvTest --config %s"%configFile
	print cmd
	args = shlex.split(cmd)
	subprocess.call(args, cwd=CWD)

