#!/bin/bash
set -e

APP_NAME="S3 Screenshot"
DMG_NAME="S3Screenshot"
VERSION="1.0"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
DMG_DIR="$BUILD_DIR/dmg-staging"
DMG_PATH="$BUILD_DIR/$DMG_NAME-$VERSION.dmg"
DEVELOPER_ID="${DEVELOPER_ID:-Developer ID Application: Matterhorn Shopping, LLC (XF9CLAMGYS)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-S3Screenshot-notary}"
NO_SIGN=false

for arg in "$@"; do
    case $arg in
        --no-sign) NO_SIGN=true ;;
    esac
done

# Step 1: Build the app (pass through --no-sign flag)
echo "==> Building app..."
if [ "$NO_SIGN" = true ]; then
    bash Scripts/build.sh --no-sign
else
    bash Scripts/build.sh
fi

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

# Step 5: Sign, notarize, and staple the DMG
if [ "$NO_SIGN" = true ]; then
    echo "==> Skipping DMG signing and notarization (--no-sign)"
else
    echo "==> Signing DMG..."
    codesign --sign "$DEVELOPER_ID" "$DMG_PATH"

    echo "==> Submitting for notarization (this may take a few minutes)..."
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait

    echo "==> Stapling notarization ticket..."
    xcrun stapler staple "$DMG_PATH"
fi

echo ""
echo "==> DMG created: $DMG_PATH"
echo "    Size: $(du -h "$DMG_PATH" | cut -f1)"
if [ "$NO_SIGN" = false ]; then
    echo "    Signed and notarized"
fi
echo ""
echo "Users open the DMG and drag '$APP_NAME' into Applications."
