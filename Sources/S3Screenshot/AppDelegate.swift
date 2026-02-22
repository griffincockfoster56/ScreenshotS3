import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var screenshotWatcher: ScreenshotWatcher?
    private var settingsWindow: NSWindow?
    private var galleryWindow: NSWindow?
    private let settingsManager = SettingsManager.shared
    private let uploader = S3Uploader()
    private let overlay = UploadOverlay()

    func applicationDidFinishLaunching(_ notification: Notification) {
        FontRegistration.registerBundledFonts()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        setupMainMenu()
        setupStatusItem()

        NSLog("[ScreenshotS3] App launched. Configured: \(settingsManager.isConfigured)")

        if settingsManager.isConfigured {
            startWatching()
            ensureBucketPublic()
        } else {
            showSettings()
        }
    }

    // MARK: - Main Menu (enables Cmd+C/V/X in text fields)

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: "ScreenshotS3")
        }

        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        if settingsManager.isConfigured {
            let status = NSMenuItem(title: "Watching for screenshots...", action: nil, keyEquivalent: "")
            status.isEnabled = false
            menu.addItem(status)

            let bucket = NSMenuItem(title: "Bucket: \(settingsManager.bucketName ?? "")", action: nil, keyEquivalent: "")
            bucket.isEnabled = false
            menu.addItem(bucket)
        } else {
            let status = NSMenuItem(title: "Not configured", action: nil, keyEquivalent: "")
            status.isEnabled = false
            menu.addItem(status)
        }

        menu.addItem(NSMenuItem.separator())
        if settingsManager.isConfigured {
            menu.addItem(NSMenuItem(title: "Gallery...", action: #selector(showGallery), keyEquivalent: "g"))
        }
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit ScreenshotS3", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: - Settings Window

    @objc private func showSettings() {
        if settingsWindow == nil {
            let view = SettingsView(onSave: { [weak self] in
                self?.settingsWindow?.close()
                self?.startWatching()
                self?.rebuildMenu()
            })

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 740),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = NSColor(red: 0.024, green: 0.024, blue: 0.06, alpha: 1)
            window.appearance = NSAppearance(named: .darkAqua)
            window.isMovableByWindowBackground = true
            window.contentView = NSHostingView(rootView: view)
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Gallery Window

    @objc private func showGallery() {
        if galleryWindow == nil {
            let view = GalleryView()

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 720, height: 580),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = NSColor(red: 0.024, green: 0.024, blue: 0.06, alpha: 1)
            window.appearance = NSAppearance(named: .darkAqua)
            window.isMovableByWindowBackground = true
            window.contentView = NSHostingView(rootView: view)
            window.minSize = NSSize(width: 520, height: 400)
            window.center()
            window.isReleasedWhenClosed = false
            galleryWindow = window
        }

        galleryWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Ensure bucket is public

    private func ensureBucketPublic() {
        guard let accessKey = settingsManager.accessKeyId,
              let secretKey = settingsManager.secretAccessKey,
              let region = settingsManager.region,
              let bucket = settingsManager.bucketName
        else { return }

        uploader.makeBucketPublic(bucket: bucket, accessKey: accessKey, secretKey: secretKey, region: region) { result in
            switch result {
            case .success:
                NSLog("[ScreenshotS3] Bucket public access confirmed")
            case .failure(let error):
                NSLog("[ScreenshotS3] Failed to set bucket public: %@", error.localizedDescription)
            }
        }
    }

    // MARK: - Screenshot Handling

    private func startWatching() {
        screenshotWatcher?.stop()
        screenshotWatcher = ScreenshotWatcher { [weak self] url in
            self?.handleNewScreenshot(url)
        }
        screenshotWatcher?.start()
    }

    private func handleNewScreenshot(_ fileURL: URL) {
        guard settingsManager.isConfigured else {
            NSLog("[ScreenshotS3] Not configured, skipping upload")
            return
        }

        NSLog("[ScreenshotS3] Uploading: \(fileURL.lastPathComponent)")

        DispatchQueue.main.async {
            self.statusItem.button?.image = NSImage(
                systemSymbolName: "arrow.up.circle.fill",
                accessibilityDescription: "Uploading"
            )
            self.overlay.showUploading()
        }

        uploader.upload(fileURL: fileURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):
                    NSLog("[ScreenshotS3] Upload success: \(urlString)")

                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(urlString, forType: .string)

                    self?.overlay.showSuccess(url: urlString)
                    self?.setIcon("checkmark.circle.fill", resetAfter: 2)

                case .failure(let error):
                    NSLog("[ScreenshotS3] Upload failed: \(error.localizedDescription)")

                    self?.overlay.showError(message: error.localizedDescription)
                    self?.setIcon("exclamationmark.triangle.fill", resetAfter: 3)
                }
            }
        }
    }

    // MARK: - Helpers

    private func setIcon(_ symbolName: String, resetAfter seconds: Double) {
        statusItem.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.statusItem.button?.image = NSImage(
                systemSymbolName: "camera.fill",
                accessibilityDescription: "ScreenshotS3"
            )
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
