# S3 Screenshot

A lightweight macOS menu bar app that automatically uploads screenshots to Amazon S3 and copies the public URL to your clipboard.

## Features

- **Automatic upload** — watches for new screenshots and uploads them instantly
- **Clipboard URL** — public link copied automatically after upload
- **Gallery** — browse all uploaded screenshots with thumbnails, copy URLs, or open in browser
- **Simple setup** — enter your AWS credentials, pick or create a bucket, and you're done
- **Menu bar native** — lives in your menu bar, stays out of the way

## Requirements

- macOS 13+
- Swift 5.7+
- An AWS account with S3 access

## Build

```bash
swift build -c release
bash Scripts/build.sh
```

The app bundle is created at `.build/release/S3 Screenshot.app`.

## Install

```bash
cp -r ".build/release/S3 Screenshot.app" /Applications/
```

## Setup

1. Launch the app — the settings window opens on first run
2. Enter your AWS Access Key ID and Secret Access Key
3. Pick a region and create a new bucket or select an existing one
4. Click **Save & Start**

The app automatically configures your bucket for public read access so screenshot URLs work immediately.

## Usage

- Take a screenshot as usual (Cmd+Shift+3, Cmd+Shift+4, etc.)
- The URL is copied to your clipboard automatically
- **Cmd+G** — open the gallery to browse past uploads
- **Cmd+,** — open settings

## Project Structure

```
Sources/S3Screenshot/
├── main.swift              # App entry point
├── AppDelegate.swift       # Menu bar, window management
├── ScreenshotWatcher.swift # Filesystem watcher for new screenshots
├── S3Uploader.swift        # S3 upload, list, bucket creation + signing
├── SettingsView.swift      # Settings UI
├── GalleryView.swift       # Gallery browser UI
├── SettingsManager.swift   # UserDefaults persistence
├── UploadOverlay.swift     # Upload status overlay
└── FontRegistration.swift  # Bundled Inter font loading
```
