#!/bin/bash

# Akiles Cordova iOS Build Script
# This script automates the build process for the iOS example app

set -e  # Exit on any error

echo "🚀 Starting Akiles Cordova iOS Build Process..."

# Check if we're in the example directory
if [[ ! -f "config.xml" ]]; then
    echo "❌ Error: This script must be run from the example directory"
    echo "   Run: cd akiles-cordova/example && ./build-ios.sh"
    exit 1
fi

# Check if cordova is installed
if ! command -v cordova &> /dev/null; then
    echo "❌ Error: Cordova CLI not found"
    echo "   Install with: npm install -g cordova"
    exit 1
fi

# Check if we're on macOS (required for iOS builds)
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds require macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not found"
    echo "   Install Xcode from the App Store"
    exit 1
fi

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "⚠️  Warning: CocoaPods not found"
    echo "   The AkilesSDK requires CocoaPods for installation"
    echo "   Install with: gem install cocoapods && pod setup"
    echo "   Continuing anyway - the plugin will attempt to install it..."
fi

echo "✅ Prerequisites check passed"

# Install npm dependencies
echo "📦 Installing npm dependencies..."
npm install

# Remove existing iOS platform and plugin (clean slate)
echo "🧹 Cleaning existing iOS platform and plugin..."
cordova platform remove ios 2>/dev/null || true
cordova plugin remove akiles-cordova 2>/dev/null || true

# Add iOS platform
echo "📱 Adding iOS platform..."
cordova platform add ios

# Add the Akiles plugin
echo "🔌 Adding Akiles plugin..."
cordova plugin add ../plugin

# Install CocoaPods dependencies if needed
if [ -f "platforms/ios/Podfile" ]; then
    echo "🔧 Installing CocoaPods dependencies..."
    cd platforms/ios
    pod install --repo-update
    cd ../..
fi

# Build for iOS device
echo "🔨 Building for iOS device..."
cordova build ios --device

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Open Xcode: cd platforms/ios && open AkilesCordovaExample.xcworkspace"
echo "   2. Connect your iOS device via USB"
echo "   3. Select your device as the target in Xcode"
echo "   4. Set up code signing (select your Apple Developer team)"
echo "   5. Build and run (⌘+R)"
echo ""
echo "🔧 Alternative: Run directly with Cordova:"
echo "   cordova run ios --device"
echo ""
echo "📚 For detailed instructions, see: README-iOS.md"
