#!/usr/bin/env python

from os import mkdir, makedirs, environ, chdir, getcwd, system
from os.path import join
from shutil import copy, copytree, move

# Usage
def Usage():
    return 'Usage: createversion.py <version>'

# Run Xcode
def RunXcode(project, target):
    system('/usr/bin/xcodebuild -project "%s" -target "%s" -configuration Release clean build' % (project, target))


# Get version from args
import sys
if len(sys.argv) <= 1: 
    print Usage()
    exit(1)
version = sys.argv[1]

# Change to root dir of Core Plot
chdir('..')
projectRoot = getcwd()

# Make directory bundle
desktopDir = join(environ['HOME'], 'Desktop')
releaseRootDir = join(desktopDir, 'CorePlot_' + version)
mkdir(releaseRootDir)

# Copy license and READMEs
copy('License.txt', releaseRootDir)
copytree('READMEs', join(releaseRootDir, 'READMEs'))

# Add source code
sourceDir = join(releaseRootDir, 'Source')
copytree('framework', join(sourceDir, 'framework'))
copytree('examples', join(sourceDir, 'examples'))

# Binaries
binariesDir = join(releaseRootDir, 'Binaries')
macosDir = join(binariesDir, 'MacOS')
iosDir = join(binariesDir, 'iOS')
makedirs(macosDir)
mkdir(iosDir)

# Build Mac Framework
chdir('framework')
RunXcode('CorePlot.xcodeproj', 'CorePlot')
macProductsDir = join(projectRoot, 'build/Release')
macFramework = join(macProductsDir, 'CorePlot.framework')
copytree(macFramework, join(macosDir, 'CorePlot.framework'))

# Build iOS SDK
RunXcode('CorePlot-CocoaTouch.xcodeproj', 'Build SDK')
sdkZipFile = join(desktopDir, 'CorePlot.zip')
move(sdkZipFile, iosDir)

# Build Docs
RunXcode('CorePlot.xcodeproj', 'Documentation')
RunXcode('CorePlot-CocoaTouch.xcodeproj', 'Documentation')

# Copy Docs
homeDir = environ['HOME']
docsetsDir = join(homeDir, 'Library/Developer/Shared/Documentation/DocSets')
docDir = join(releaseRootDir, 'Documentation')
copytree(join(docsetsDir, 'com.CorePlot.Framework.docset'), join(docDir, 'com.CorePlot.Framework.docset'))
copytree(join(docsetsDir, 'com.CorePlotTouch.Framework.docset'), join(docDir, 'com.CorePlotTouch.Framework.docset'))

