#!/usr/bin/env python

from os import mkdir, makedirs, environ, chdir, getcwd, system, listdir
from os.path import join
from shutil import copy, copytree, move, rmtree, ignore_patterns

# Usage
def Usage():
    return 'Usage: createrelease.py <version>'

# Run Xcode
def RunXcode(project, target):
    system('/usr/bin/xcodebuild -project "%s" -target "%s" -configuration Release clean build' % (project, target))


# Get version from args
import sys
if len(sys.argv) <= 1: 
    print(Usage())
    exit(1)
version = sys.argv[1]

# Change to root dir of Core Plot
chdir('..')
projectRoot = getcwd()

# Remove old docset files
frameworkDir = join(projectRoot, 'framework')
rmtree(join(frameworkDir, 'CorePlotDocs.docset'), True)
rmtree(join(frameworkDir, 'CorePlotTouchDocs.docset'), True)

# Remove old build directories
rmtree(join(projectRoot, 'build'), True)
rmtree(join(frameworkDir, 'build'), True)
examples = listdir('examples')
for ex in examples:
    exampleDir = join('examples', ex)
    rmtree(join(exampleDir, 'build'), True)

# Make directory bundle
desktopDir = join(environ['HOME'], 'Desktop')
releaseRootDir = join(desktopDir, 'CorePlot_' + version)
mkdir(releaseRootDir)

# Copy license and READMEs
copy('License.txt', releaseRootDir)
copytree('READMEs', join(releaseRootDir, 'READMEs'), ignore=ignore_patterns('*.orig'))

# Copy podspec
copy('CorePlot.podspec', releaseRootDir)

# Add source code
sourceDir = join(releaseRootDir, 'Source')
copytree('framework', join(sourceDir, 'framework'), ignore=ignore_patterns('*.docset','*.orig'))
copytree('examples', join(sourceDir, 'examples'), ignore=ignore_patterns('*.orig'))
copy('License.txt', sourceDir)

# Binaries
binariesDir = join(releaseRootDir, 'Binaries')
macosDir = join(binariesDir, 'MacOS')
universalDir = join(binariesDir, 'All')
makedirs(macosDir)
mkdir(universalDir)

# Build Mac Framework
chdir('framework')
RunXcode('CorePlot.xcodeproj', 'CorePlot Mac')
macProductsDir = join(frameworkDir, 'build/Release')
macFramework = join(macProductsDir, 'CorePlot.framework')
copytree(macFramework, join(macosDir, 'CorePlot.framework'), symlinks=True)

# Build Universal Framework
RunXcode('CorePlot.xcodeproj', 'Universal XCFramework')
universalProductsDir = join(projectRoot, 'build/Release-universal')
universalFramework = join(universalProductsDir, 'CorePlot.xcframework')
copytree(universalFramework, join(universalDir, 'CorePlot.xcframework'), symlinks=True)

# Build Docs
RunXcode('CorePlot.xcodeproj', 'Documentation-Mac')
RunXcode('CorePlot.xcodeproj', 'Documentation-iOS')

# Copy Docs
docDir = join(releaseRootDir, 'Documentation')
copytree(join(projectRoot, 'documentation'), docDir, ignore=ignore_patterns('*.orig','*.git'))
