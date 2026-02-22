import Foundation

class ScreenshotWatcher {
    private var dispatchSource: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1
    private var knownFiles: Set<String> = []
    private var processedFiles: Set<String> = []
    private let watchDirectory: String
    private let onNewScreenshot: (URL) -> Void

    init(onNewScreenshot: @escaping (URL) -> Void) {
        self.onNewScreenshot = onNewScreenshot

        if let location = UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location") {
            self.watchDirectory = (location as NSString).expandingTildeInPath
        } else {
            self.watchDirectory = NSHomeDirectory() + "/Desktop"
        }
    }

    func start() {
        knownFiles = Set(screenshotFilenames())
        NSLog("[ScreenshotS3] Watching %@ — %d existing screenshots", watchDirectory, knownFiles.count)

        fileDescriptor = open(watchDirectory, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            NSLog("[ScreenshotS3] Failed to open directory for monitoring, falling back to polling")
            startPolling()
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.global(qos: .userInitiated)
        )

        source.setEventHandler { [weak self] in
            self?.checkForNewFiles()
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        dispatchSource = source
        source.resume()
    }

    func stop() {
        dispatchSource?.cancel()
        dispatchSource = nil
    }

    // MARK: - Detection

    private func checkForNewFiles() {
        let currentFiles = Set(screenshotFilenames())
        let newFiles = currentFiles.subtracting(knownFiles).subtracting(processedFiles)

        for filename in newFiles {
            let url = URL(fileURLWithPath: watchDirectory).appendingPathComponent(filename)
            processedFiles.insert(filename)

            waitForStableSize(url) { [weak self] in
                NSLog("[ScreenshotS3] New screenshot detected: \(filename)")
                self?.onNewScreenshot(url)
            }
        }

        knownFiles = currentFiles
    }

    // MARK: - File stability

    private func waitForStableSize(_ url: URL, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var lastSize: UInt64 = 0

            // Quick checks at 0.15s intervals — screenshots finish writing fast
            for _ in 0..<12 {
                guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let size = attrs[.size] as? UInt64 else {
                    Thread.sleep(forTimeInterval: 0.15)
                    continue
                }
                if size > 0 && size == lastSize {
                    completion()
                    return
                }
                lastSize = size
                Thread.sleep(forTimeInterval: 0.15)
            }

            // File never stabilized but has content — upload anyway
            if lastSize > 0 { completion() }
        }
    }

    // MARK: - Polling fallback

    private var timer: Timer?

    private func startPolling() {
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.checkForNewFiles()
            }
        }
    }

    // MARK: - Helpers

    private func screenshotFilenames() -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: watchDirectory) else {
            NSLog("[ScreenshotS3] Cannot read directory: \(watchDirectory)")
            return []
        }
        return files.filter { isScreenshot($0) }
    }

    private func isScreenshot(_ filename: String) -> Bool {
        let lower = filename.lowercased()
        let hasPrefix = lower.hasPrefix("screenshot") || lower.hasPrefix("screen shot")
        let hasExt = lower.hasSuffix(".png") || lower.hasSuffix(".jpg")
            || lower.hasSuffix(".jpeg") || lower.hasSuffix(".tiff")
        return hasPrefix && hasExt
    }
}
