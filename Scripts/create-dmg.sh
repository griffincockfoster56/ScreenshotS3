#!/bin/bash
set -e

APP_NAME="S3 Screenshot"
DMG_NAME="S3Screenshot"
VERSION="1.0"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
DMG_DIR="$BUILD_DIR/dmg-staging"
DMG_PATH="$BUILD_DIR/$DMG_NAME-$VERSION.dmg"

# Step 1: Build the app
echo "==> Building app..."
bash Scripts/build.sh

# Step 2: Prepare DMG staging folder
echo "==> Preparing DMG contents..."
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
cp -r "$APP_DIR" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

# Step 3: Create the DMG
echo "==> Creating DMG..."
rm -f "$DMG_PATH"
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

# Step 4: Clean up
rm -rf "$DMG_DIR"

echo ""
echo "==> DMG created: $DMG_PATH"
echo "    Size: $(du -h "$DMG_PATH" | cut -f1)"
echo ""
echo "Users open the DMG and drag '$APP_NAME' into Applications."
