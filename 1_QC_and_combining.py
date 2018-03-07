#!/usr/bin/python3

import re
import sys
import string
import os
import os.path
from glob import glob
from os import listdir
from os.path import isfile, join
import gc

del sys.argv[0]

#print(len(sys.argv))
#print(sys.argv)
if len(sys.argv) >2:
	sys.exit('Incorrect number of arguments supplied. If one is supplied, it must be the minimum number of copies for a sequence to be included. If no argument supplied, this defaults to 1')

if len(sys.argv) ==0:
	min_thresh = int(1)
	splitBy = '_'

if len(sys.argv) ==2:
	min_thresh = int(sys.argv[0])
	splitBy = str(sys.argv[1])


wd = os.getcwd()

outFile = 'all_post_QC.fasta'
outData= open(outFile, mode = 'w')

allFiles = os.listdir(wd)

inFiles = [ fi for fi in allFiles if fi.endswith(".fasta") ]

#print(inFiles)
seqNamesList = []
i = 1
for file in inFiles:
	fileName = file.replace('.fasta', '')
	fileName = fileName.replace(' ', '_')
	fileData = open(file)
	for line in fileData:
		line = line.rstrip()
		#print(line)
		if splitBy in line:
			lineList = line.split(splitBy)
			nCopies = lineList[-1]
			#print(nCopies)
			lineList[0] = lineList[0].replace('>', '')
			newLine = '>' + fileName + '_' + lineList[-2] + "_" +  nCopies #Give us the filename and the number of copies, exclude the rest
			#if newLine in seqNamesList:
			#	newLine = '>' + fileName + '_' + lineList[-2] + "b_" +  nCopies #Same as above, but this kills duplicates that sometimes otherwise occur
			#seqNamesList.append(newLine)
			nextLine = next(fileData)
			if int(nCopies) > min_thresh: #If the number of copies of that sequence is above our minimum threshold, we write it to the new file
				outData.write(newLine + '\n' + nextLine)


outData.close()

