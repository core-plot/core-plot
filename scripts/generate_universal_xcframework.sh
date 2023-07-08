#!/bin/sh

UFW_MAC_TARGET="CorePlot Mac"
UFW_IOS_TARGET="CorePlot iOS"
UFW_TVOS_TARGET="CorePlot tvOS"

UFW_BUILD_DIR="${PROJECT_DIR}/../build"

# Mac SDK
# Use the latest macOS SDK available
UFW_GREP_RESULT=$(xcodebuild -showsdks | grep -o "[^.]macosx.*$")
while read -r line; do
UFW_MAC_SDK_VERSION="${line}"
done <<< "${UFW_GREP_RESULT}"
UFW_MAC_SDK_VERSION=$(echo "${UFW_MAC_SDK_VERSION}" | grep -o "[0-9].*$")

# iOS SDK
# Use the latest iOS SDK available
UFW_GREP_RESULT=$(xcodebuild -showsdks | grep -o "iphoneos.*$")
while read -r line; do
UFW_IOS_SDK_VERSION="${line}"
done <<< "${UFW_GREP_RESULT}"
UFW_IOS_SDK_VERSION=$(echo "${UFW_IOS_SDK_VERSION}" | grep -o "[0-9].*$")

# tvOS SDK
# Use the latest tvOS SDK available
UFW_GREP_RESULT=$(xcodebuild -showsdks | grep -o "appletvos.*$")
while read -r line; do
UFW_TVOS_SDK_VERSION="${line}"
done <<< "${UFW_GREP_RESULT}"
UFW_TVOS_SDK_VERSION=$(echo "${UFW_TVOS_SDK_VERSION}" | grep -o "[0-9].*$")

FRAMEWORK_NAME="${PROJECT_NAME}"

UFW_MAC_PATH="${UFW_BUILD_DIR}/Release/${FRAMEWORK_NAME}.framework"
UFW_CATALYST_PATH="${UFW_BUILD_DIR}/Release-maccatalyst/${FRAMEWORK_NAME}.framework"
UFW_IOS_PATH="${UFW_BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework"
UFW_IOS_SIMULATOR_PATH="${UFW_BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework"
UFW_TVOS_PATH="${UFW_BUILD_DIR}/Release-appletvos/${FRAMEWORK_NAME}.framework"
UFW_TVOS_SIMULATOR_PATH="${UFW_BUILD_DIR}/Release-appletvsimulator/${FRAMEWORK_NAME}.framework"

UFW_UNIVERSAL_DIR="${UFW_BUILD_DIR}/Release-universal"
UFW_FRAMEWORK="${UFW_UNIVERSAL_DIR}/${FRAMEWORK_NAME}.xcframework"

# Build Framework

rm -rf "${UFW_UNIVERSAL_DIR}"

# macOS
xcodebuild -scheme "${UFW_MAC_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk macosx${UFW_MAC_SDK_VERSION} clean build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
# Mac Catalyst
xcodebuild -scheme "${UFW_IOS_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk iphoneos${UFW_IOS_SDK_VERSION} -destination "platform=macOS,variant=Mac Catalyst" build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
# iOS
xcodebuild -scheme "${UFW_IOS_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk iphoneos${UFW_IOS_SDK_VERSION} build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
xcodebuild -scheme "${UFW_IOS_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk iphonesimulator${UFW_IOS_SDK_VERSION} build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
#tvOS
xcodebuild -scheme "${UFW_TVOS_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk appletvos${UFW_TVOS_SDK_VERSION} build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
xcodebuild -scheme "${UFW_TVOS_TARGET}" -project CorePlot.xcodeproj -configuration Release -sdk appletvsimulator${UFW_TVOS_SDK_VERSION} build SYMROOT="${UFW_BUILD_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi

mkdir -p "${UFW_UNIVERSAL_DIR}"
if [ "$?" != "0" ]; then echo >&2 "Error: mkdir failed"; exit 1; fi

xcodebuild -create-xcframework -output "${UFW_FRAMEWORK}" \
    -framework "${UFW_MAC_PATH}" \
    -framework "${UFW_CATALYST_PATH}" \
    -framework "${UFW_IOS_PATH}" \
    -framework "${UFW_IOS_SIMULATOR_PATH}" \
    -framework "${UFW_TVOS_PATH}" \
    -framework "${UFW_TVOS_SIMULATOR_PATH}"
if [ "$?" != "0" ]; then echo >&2 "Error: create XCFramework failed"; exit 1; fi

exit 0
