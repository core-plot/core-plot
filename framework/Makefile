DEST=dist/CorePlotSDK
XCODEBUILDFLAGS=-parallelizeTargets -configuration Release -target CorePlot-CocoaTouch -project CorePlot-CocoaTouch.xcodeproj

all: clean sdk

sdk: iphoneos iphonesimulator
	cd dist && rm -f ../coreplot.zip
	cd dist && zip -r ../coreplot.zip CorePlotSDK

clean:
	rm -rf build dist coreplot.zip

iphoneos iphonesimulator:
	xcodebuild ${XCODEBUILDFLAGS} -sdk $@3.0
	mkdir -p ${DEST}/$@.sdk/usr/include/CorePlot
	mkdir -p ${DEST}/$@.sdk/usr/lib
	cp -a build/Release-$@/usr/local/include/* ${DEST}/$@.sdk/usr/include/CorePlot
	cp -a build/Release-$@/libCorePlot-CocoaTouch.a ${DEST}/$@.sdk/usr/lib/libCorePlot.a
	cp $@-SDKSettings.plist ${DEST}/$@.sdk/SDKSettings.plist
	sed -f cp.sed build/Release-$@/usr/local/include/CorePlot-CocoaTouch.h > ${DEST}/$@.sdk/usr/include/CorePlot/CorePlot.h

# Would like to do it without the external sed command file, but I 
# can't get the interpreter to behave.
#
#	sed -e "s/\"$/>/" \
		-e "s/\"Source/<CorePlot/" \
		-e "s/\"iPhoneOnly/<CorePlot/" \
		build/Release-$@/usr/local/include/CorePlot-CocoaTouch.h > ${DEST}/$@.sdk/usr/include/CorePlot/CorePlot.h

.PHONY: iphoneos iphonesimulator clean all sdk
