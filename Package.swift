// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "S3Screenshot",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "S3Screenshot",
            path: "Sources/S3Screenshot"
        )
    ]
)
