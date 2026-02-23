#!/bin/bash
set -e

APP_NAME="S3 Screenshot"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
DEVELOPER_ID="${DEVELOPER_ID:-Developer ID Application}"
NO_SIGN=false

for arg in "$@"; do
    case $arg in
        --no-sign) NO_SIGN=true ;;
    esac
done

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

# Code sign the app bundle
if [ "$NO_SIGN" = true ]; then
    echo "==> Skipping code signing (--no-sign)"
else
    echo "==> Code signing app bundle..."
    codesign --deep --force --verify --verbose \
        --sign "$DEVELOPER_ID" \
        --options runtime \
        --entitlements Resources/S3Screenshot.entitlements \
        "$APP_DIR"
    echo "==> Verifying signature..."
    codesign --verify --deep --strict "$APP_DIR"
fi

echo "==> Done!"
echo ""
echo "App bundle: $APP_DIR"
echo ""
echo "To install:  cp -r \"$APP_DIR\" /Applications/"
echo "To run:      open \"$APP_DIR\""
