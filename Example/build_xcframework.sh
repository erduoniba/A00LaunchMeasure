#!/bin/bash

WORKSPACE_NAME="A00LaunchMeasure.xcworkspace"

# Cleanup
rm -rf build

# 使用源码安装
IS_SOURCE=1 pod install

if [ $? -ne 0 ]; then
    echo "pod install failed. Exiting..."
    exit 1
fi

build_xcframework() {
    # Build for iOS Device
    xcodebuild archive \
      -workspace $WORKSPACE_NAME \
      -scheme $1 \
      -configuration Release only_active_arch=no \
      -sdk iphoneos \
      -archivePath build/ios_devices.xcarchive \
      SKIP_INSTALL=NO \
      BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

    if [ $? -ne 0 ]; then
        echo "Build $1 for iOS Device failed. Exiting..."
        exit 1
    fi

    # Build for iOS Simulator
    xcodebuild archive \
      -workspace $WORKSPACE_NAME \
      -scheme $1 \
      -configuration Release only_active_arch=no \
      -sdk iphonesimulator \
      -archivePath build/ios_simulator.xcarchive \
      SKIP_INSTALL=NO \
      BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


    if [ $? -ne 0 ]; then
        echo "Build $1 for iOS Simulator failed. Exiting..."
        exit 1
    fi

    # Create XCFramework
    xcodebuild -create-xcframework \
      -framework build/ios_devices.xcarchive/Products/Library/Frameworks/$1.framework \
      -framework build/ios_simulator.xcarchive/Products/Library/Frameworks/$1.framework \
      -output build/$1.xcframework

    # Remove archives
    rm -rf build/ios_devices.xcarchive
    rm -rf build/ios_simulator.xcarchive

    if [ $? -ne 0 ]; then
        echo "Create $1 XCFramework failed. Exiting..."
        exit 1
    fi
}

build_xcframework A00LaunchMeasure