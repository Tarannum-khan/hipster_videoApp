#!/bin/bash

# Hipster Video - Build Script
# This script helps build the app for different platforms

echo "🚀 Hipster Video - Build Script"
echo "================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get Flutter version
echo "📱 Flutter version:"
flutter --version

# Clean and get dependencies
echo "🧹 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

# Build for Android
echo "🤖 Building Android APK..."
flutter build apk --release

# Build for Android App Bundle (for Play Store)
echo "📦 Building Android App Bundle..."
flutter build appbundle --release

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release
else
    echo "⚠️  iOS build skipped (not on macOS)"
fi

echo "✅ Build completed!"
echo ""
echo "📁 Output files:"
echo "   Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   Android AAB: build/app/outputs/bundle/release/app-release.aab"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   iOS: build/ios/Release-iphoneos/Runner.app"
fi

echo ""
echo "🎉 Ready for deployment!"









