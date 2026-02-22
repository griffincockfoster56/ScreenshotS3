#!/bin/bash
set -e

APP_NAME="S3 Screenshot"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "==> Building S3 Screenshot..."
swift build -c release

echo "==> Creating app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/S3Screenshot" "$APP_DIR/Contents/MacOS/S3Screenshot"
cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"

# Bundle app icon
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

# Bundle Inter fonts
if [ -d "Resources/Fonts" ]; then
    cp -r Resources/Fonts "$APP_DIR/Contents/Resources/Fonts"
fi

echo "==> Done!"
echo ""
echo "App bundle: $APP_DIR"
echo ""
echo "To install:  cp -r \"$APP_DIR\" /Applications/"
echo "To run:      open \"$APP_DIR\""
