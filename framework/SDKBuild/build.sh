#!/bin/sh

set -e -u

BUILD="${PWD}/../../build"
SDK_VERSION=4.1

rm -rf Distribution

XCODEBUILDFLAGS="-parallelizeTargets -configuration Release -target CorePlot-CocoaTouch -project ../CorePlot-CocoaTouch.xcodeproj"

for x_sdk in iphoneos iphonesimulator ; do 
	BASESDK_DIR=Distribution/CorePlotSDK/${x_sdk}.sdk
	xcodebuild $XCODEBUILDFLAGS SYMROOT="$BUILD" -sdk ${x_sdk}${SDK_VERSION}
	mkdir -p "$BASESDK_DIR/usr/include/CorePlot"
	mkdir -p "$BASESDK_DIR/usr/lib"

	cp -a "$BUILD/Release-$x_sdk/usr/local/include/"* "$BASESDK_DIR/usr/include/CorePlot"
	cp -a "$BUILD/Release-$x_sdk/libCorePlot-CocoaTouch.a" "$BASESDK_DIR/usr/lib/libCorePlot.a"
	cp $x_sdk-SDKSettings.plist "$BASESDK_DIR/SDKSettings.plist"
	sed -f cp.sed "$BUILD/Release-$x_sdk/usr/local/include/CorePlot-CocoaTouch.h" > "$BASESDK_DIR/usr/include/CorePlot/CorePlot.h"
done

cd Distribution
rm -f ../CorePlot.zip
zip -r ../CorePlot.zip CorePlotSDK ../README.txt
cd ..
rm -r Distribution
