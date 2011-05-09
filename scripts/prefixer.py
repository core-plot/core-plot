#!/usr/bin/env python

#---------
# Script to change the prefix of a framework
#---------

import os
import re
import string

#------------------
# Config
#------------------
oldPrefix = "CP"  # Set to empty string if there is no old prefix
newPrefix = "CPT"

# Root directories
origRootDir = "/Users/cormack/Desktop/CorePlotReprefix"
newRootDir  = "/Users/cormack/Desktop/CorePlotReprefixNew"

#------------------
# Algorithm
#------------------

# Prefix strings in files in a single directory
def treatDirectory(arg, dirName, names):

    dirRelativeToRoot = dirName[len(origRootDir):]
    destDir = newRootDir + dirRelativeToRoot
    
    print "Converting dir %s" % (dirName)

    if not os.path.exists(destDir): os.mkdir(destDir)

    filePrefixRegexString = "^(?P<type>_?)" + oldPrefix + "(?P<name>.+)$"
    filePrefixRegex = re.compile(filePrefixRegexString)
    contentPrefixRegex = re.compile("(?P<type>(k|_)?)" + oldPrefix + "(?P<name>\w+)")
    fileSubString = "\g<type>" + newPrefix + "\g<name>"
    contentSubString = "\g<type>" + newPrefix + "\g<name>"
    for fileName in names:
        fromPath = dirName + "/" + fileName
        toPath = destDir + "/" + filePrefixRegex.sub(fileSubString, fileName)

        if os.path.isfile(fromPath):
            fromFile = open(fromPath, 'r')
            toFile = open(toPath, 'w')
            newFileContent = contentPrefixRegex.sub( contentSubString, fromFile.read() )
            toFile.write(newFileContent)
            fromFile.close()
            toFile.close()

# Create new dir if necessary
if not os.path.exists(newRootDir): os.mkdir(newRootDir)
    
# Walk over all files in original directory
os.path.walk(origRootDir, treatDirectory, None)

