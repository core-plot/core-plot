#!/bin/sh

set -e -u

rm -rf build Distribution

XCODEBUILDFLAGS="-parallelizeTargets -configuration Release -target CorePlot-CocoaTouch -project CorePlot-CocoaTouch.xcodeproj"

#xcodebuild -parallelizeTargets -configuration Debug -sdk iphoneos3.0
#xcodebuild -parallelizeTargets -configuration Debug -sdk iphonesimulator3.0

for x_sdk in iphoneos iphonesimulator ; do 
	BASESDK_DIR=Distribution/CorePlotSDK/${x_sdk}.sdk
	echo "xcodebuild $XCODEBUILDFLAGS -sdk iphoneos3.0"
	xcodebuild $XCODEBUILDFLAGS -sdk iphoneos3.0
	xcodebuild $XCODEBUILDFLAGS -sdk iphonesimulator3.0
	mkdir -p $BASESDK_DIR/usr/include/CorePlot
	mkdir -p $BASESDK_DIR/usr/lib

	cp -a build/Release-$x_sdk/usr/local/include/* $BASESDK_DIR/usr/include/CorePlot
	cp -a build/Release-$x_sdk/libCorePlot-CocoaTouch.a $BASESDK_DIR/usr/lib/libCorePlot.a
	cp $x_sdk-SDKSettings.plist $BASESDK_DIR/SDKSettings.plist
	sed -f cp.sed build/Release-$x_sdk/usr/local/include/CorePlot-CocoaTouch.h > $BASESDK_DIR/usr/include/CorePlot/CorePlot.h
done

cd Distribution
rm -f ../coreplot.zip
zip -r ../coreplot.zip CorePlotSDK
