from utils import *
from executors import *

configFiles = {
	'NormFeat-Energy'			: "../cfg/NormFeat_energy_SPro.cfg",
	'Energy-Detector'			: "../cfg/EnergyDetector_SPro.cfg",
	'NormFeat'					: "../cfg/NormFeat_SPro.cfg",
	'TrainWorld'				: {
									"M"	:	"../cfg/TrainWorld-M.cfg",
									"F"	:	"../cfg/TrainWorld-F.cfg"
								},
	'TotalVariabilityMatrix'	: {
									"M"	:	"../cfg/TotalVariability_fast-M.cfg",
									"F"	:	"../cfg/TotalVariability_fast-F.cfg"
								},
	'IVectorExtractor'			: {
									"M"	:	"../cfg/ivExtractor_fast-M.cfg",
									"F"	:	"../cfg/ivExtractor_fast-F.cfg"
								},
}



def trainUBM(sourceFolder, gender):
	dataList = "../data/UBM/UBM-%s.lst"%gender
	ndxFile = "../data/UBM/NDX/totalvariability-%s.ndx"%gender
	NdxFileIVec = "../data/UBM/NDX/ivExtractor-%s.ndx"%gender
	sourceDataExtn = "sph"
	featureFilesPath = "../data/UBM/PRM/%s/"%gender
	labelFilesPath = "../data/UBM/LBL/%s/"%gender
	writeListToFile(getFilesFromFolder(sourceFolder), dataList)
	writeListToFile(getFilesFromFolder(sourceFolder), ndxFile)
	writeListTwiceToFile(getFilesFromFolder(sourceFolder), NdxFileIVec)
	extractMFCC_UBM(dataList, sourceDataExtn, sourceFolder, featureFilesPath)
	normalizeFeatures_UBM(dataList, featureFilesPath, configFiles['NormFeat-Energy'])
	detectEnergy_UBM(dataList, configFiles['Energy-Detector'], featureFilesPath, labelFilesPath)
	normalizeFeatures2_UBM(dataList, configFiles['NormFeat'], featureFilesPath, labelFilesPath)
	trainWorld_UBM(configFiles['TrainWorld'][gender])
	totalVariabilityMatrix_UBM(configFiles['TotalVariabilityMatrix'][gender])
	extractIVectors(configFiles['IVectorExtractor'][gender])

def test(testFolder, testFile, speaker, UBMSourceFolder, gender):
	"""
		All the files created here should be deleted after 
		completion of the function
	"""
	########### Filenames to be used in the config files ###################
	# Verify the membership of the file with the speaker
	NdxFileTestIVec = "../data/NDX/%s"%speaker 
	# Store outputs
	outputFilename = getTestingFilePath("OUTPUT", speaker)
	# Generate Ivectors for the following entries
	NdxIdExtractor = "../data/NDX/%s-idExtractor"%speaker


	testFileWithoutExt = testFile.split(".")[0]
	########### Generating the files that will be used in config files ################
	# This is used to check the membership of the file with the speaker
	prepareNdxFileName(NdxFileTestIVec, testFileWithoutExt, speaker)
	# This file is used to generate ivectors for the file
	prepareNdxIdExtractor(NdxIdExtractor, testFileWithoutExt)
	
	###################### Generation of config files ########################
	IVEXTRACTOR_CONFIG_FILE = "../cfg/ivExtractorTest_fast-%s.cfg"%speaker
	generateConfigFile(
		"../cfg/ivExtractorTest_fast-%s.templ.cfg"%gender, 
		{'targetIdList'			:	NdxIdExtractor}, 
		"../cfg/ivExtractorTest_fast-%s.cfg"%speaker
	)
	IVTEST_CONFIG_FILE = "../cfg/ivTest_WCCN_Cosine-%s.cfg"%speaker
	generateConfigFile(
		"../cfg/ivTest_WCCN_Cosine-%s.templ.cfg"%gender,
		{
			'outputFilename'	:	outputFilename,
		 	'ndxFilename'		:	NdxFileTestIVec,
		},
		"../cfg/ivTest_WCCN_Cosine-%s.cfg"%speaker,
	)

	########################## Static Information ##########################
	sourceDataExtn = "sph"
	featureFilesPath = "../data/PRM/%s/"%gender
	labelFilesPath = "../data/LBL/%s/"%gender

	########################## Input preparation ###########################
	testDataList = "../data/test.lst"
	prepareInlineDataList(testFileWithoutExt, testDataList)

	extractMFCC(testFolder, testFile, featureFilesPath, testFileWithoutExt+".tmp.prm")
	normalizeFeatures(featureFilesPath, testDataList, configFiles['NormFeat-Energy'])
	detectEnergy(configFiles["Energy-Detector"], testDataList, featureFilesPath, labelFilesPath)
	normalizeFeatures2(configFiles["NormFeat"], testDataList, featureFilesPath, labelFilesPath)
	extractIVectors(IVEXTRACTOR_CONFIG_FILE)
	testIVectors(IVTEST_CONFIG_FILE)

