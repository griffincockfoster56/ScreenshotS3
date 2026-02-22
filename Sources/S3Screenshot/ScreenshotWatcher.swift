import Foundation

class ScreenshotWatcher {
    private var timer: Timer?
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
        // Snapshot current screenshots so we only react to new ones
        knownFiles = Set(screenshotFilenames())
        NSLog("[ScreenshotS3] Watching %@ — %d existing screenshots", watchDirectory, knownFiles.count)

        // Poll every 1.5 seconds (reliable, low overhead, no permission issues)
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private

    private func poll() {
        let currentFiles = Set(screenshotFilenames())
        let newFiles = currentFiles.subtracting(knownFiles).subtracting(processedFiles)

        for filename in newFiles {
            let url = URL(fileURLWithPath: watchDirectory).appendingPathComponent(filename)

            // Make sure the file is fully written before uploading
            processedFiles.insert(filename)
            waitForStableSize(url) { [weak self] in
                NSLog("[ScreenshotS3] New screenshot detected: \(filename)")
                self?.onNewScreenshot(url)
            }
        }

        knownFiles = currentFiles
    }

    private func screenshotFilenames() -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: watchDirectory) else {
            NSLog("[ScreenshotS3] Cannot read directory: \(watchDirectory)")
            return []
        }
        return files.filter { isScreenshot($0) }
    }

    private func waitForStableSize(_ url: URL, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var lastSize: UInt64 = 0
            var stableCount = 0

            for _ in 0..<10 {
                guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let size = attrs[.size] as? UInt64 else {
                    Thread.sleep(forTimeInterval: 0.5)
                    continue
                }
                if size > 0 && size == lastSize {
                    stableCount += 1
                    if stableCount >= 2 {
                        completion()
                        return
                    }
                } else {
                    stableCount = 0
                }
                lastSize = size
                Thread.sleep(forTimeInterval: 0.5)
            }

            if lastSize > 0 { completion() }
        }
    }

    private func isScreenshot(_ filename: String) -> Bool {
        let lower = filename.lowercased()
        let hasPrefix = lower.hasPrefix("screenshot") || lower.hasPrefix("screen shot")
        let hasExt = lower.hasSuffix(".png") || lower.hasSuffix(".jpg")
            || lower.hasSuffix(".jpeg") || lower.hasSuffix(".tiff")
        return hasPrefix && hasExt
    }
}
