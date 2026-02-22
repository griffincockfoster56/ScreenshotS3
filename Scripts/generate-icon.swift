#!/usr/bin/env swift
// generate-icon.swift — Generates AppIcon.icns matching the LogoView design
// Usage: swift Scripts/generate-icon.swift

import AppKit
import CoreGraphics
import Foundation

// MARK: - Configuration

let iconSize: CGFloat = 1024
let outputDir = "Resources/AppIcon.iconset"
let icnsOutput = "Resources/AppIcon.icns"

// Colors
let gradientStart = NSColor(red: 0x66/255, green: 0x7e/255, blue: 0xea/255, alpha: 1) // #667eea
let gradientEnd = NSColor(red: 0x76/255, green: 0x4b/255, blue: 0xa2/255, alpha: 1) // #764ba2
let greenBadge = NSColor(red: 0x34/255, green: 0xd3/255, blue: 0x99/255, alpha: 1) // #34d399

// MARK: - Drawing

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        fatalError("Could not get graphics context")
    }

    let scale = size / 1024

    // --- Background: rounded rect with continuous corners (squircle) ---
    let inset: CGFloat = 24 * scale
    let rect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let cornerRadius: CGFloat = 220 * scale

    let bgPath = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Draw gradient background
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [gradientStart.cgColor, gradientEnd.cgColor] as CFArray
    let locations: [CGFloat] = [0, 1]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.minX, y: rect.maxY),
            end: CGPoint(x: rect.maxX, y: rect.minY),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
    }
    ctx.restoreGState()

    // Subtle white border on rounded rect
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
    ctx.setLineWidth(3 * scale)
    ctx.strokePath()
    ctx.restoreGState()

    // --- Center coordinates for icon design ---
    let cx = size / 2
    let cy = size / 2

    // --- Bucket handle arc ---
    ctx.saveGState()
    let handleCenterX = cx
    let handleCenterY = cy + 80 * scale
    let handleRadius: CGFloat = 140 * scale
    let handleStartAngle = CGFloat.pi * 15 / 180   // ~15 degrees (inverted Y)
    let handleEndAngle = CGFloat.pi * 165 / 180     // ~165 degrees

    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.7).cgColor)
    ctx.setLineWidth(32 * scale)
    ctx.setLineCap(.round)
    ctx.addArc(center: CGPoint(x: handleCenterX, y: handleCenterY),
               radius: handleRadius,
               startAngle: handleStartAngle,
               endAngle: handleEndAngle,
               clockwise: false)
    ctx.strokePath()
    ctx.restoreGState()

    // --- Person silhouette (SF Symbol person.fill) ---
    // Draw using NSAttributedString with SF Symbols
    ctx.saveGState()
    let personSize: CGFloat = 280 * scale
    if let personFont = NSFont(name: "SF Pro", size: personSize) ?? NSFont.systemFont(ofSize: personSize, weight: .semibold) as NSFont? {
        let config = NSImage.SymbolConfiguration(pointSize: personSize, weight: .semibold)
        if let personImage = NSImage(systemSymbolName: "person.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) {

            let personRect = CGRect(
                x: cx - personSize * 0.5,
                y: cy - personSize * 0.15,
                width: personSize,
                height: personSize
            )

            // Tint it white
            let tinted = NSImage(size: personImage.size)
            tinted.lockFocus()
            NSColor.white.set()
            let tintRect = NSRect(origin: .zero, size: personImage.size)
            personImage.draw(in: tintRect)
            tintRect.fill(using: .sourceAtop)
            tinted.unlockFocus()

            tinted.draw(in: personRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
    }
    ctx.restoreGState()

    // --- Bucket body (trapezoid with curved bottom) ---
    ctx.saveGState()
    let bucketPath = CGMutablePath()
    let bTop = cy + 10 * scale        // top of bucket body
    let bBottom = bTop + 300 * scale   // bottom of bucket body
    let bTopLeft = cx - 260 * scale
    let bTopRight = cx + 260 * scale
    let bBottomLeft = cx - 210 * scale
    let bBottomRight = cx + 210 * scale

    bucketPath.move(to: CGPoint(x: bTopLeft, y: bTop))
    bucketPath.addLine(to: CGPoint(x: bTopRight, y: bTop))
    bucketPath.addLine(to: CGPoint(x: bBottomRight, y: bBottom))
    bucketPath.addQuadCurve(to: CGPoint(x: bBottomLeft, y: bBottom),
                            control: CGPoint(x: cx, y: bBottom + 50 * scale))
    bucketPath.closeSubpath()

    ctx.addPath(bucketPath)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.2).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // --- Bucket rim (capsule) ---
    ctx.saveGState()
    let rimWidth: CGFloat = 520 * scale
    let rimHeight: CGFloat = 60 * scale
    let rimRect = CGRect(x: cx - rimWidth/2, y: bTop - rimHeight/2, width: rimWidth, height: rimHeight)
    let rimPath = CGPath(roundedRect: rimRect, cornerWidth: rimHeight/2, cornerHeight: rimHeight/2, transform: nil)
    ctx.addPath(rimPath)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.45).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // --- Upload badge (green circle with arrow) ---
    ctx.saveGState()
    let badgeSize: CGFloat = 280 * scale
    let badgeCenterX = cx + 280 * scale
    let badgeCenterY = cy + 280 * scale  // CoreGraphics Y is flipped from SwiftUI
    let badgeRect = CGRect(x: badgeCenterX - badgeSize/2, y: badgeCenterY - badgeSize/2,
                           width: badgeSize, height: badgeSize)

    // White outline behind badge
    let outlineSize = badgeSize + 40 * scale
    let outlineRect = CGRect(x: badgeCenterX - outlineSize/2, y: badgeCenterY - outlineSize/2,
                             width: outlineSize, height: outlineSize)
    ctx.addEllipse(in: outlineRect)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.15).cgColor)
    ctx.fillPath()

    // Green circle
    ctx.addEllipse(in: badgeRect)
    ctx.setFillColor(greenBadge.cgColor)
    ctx.fillPath()

    // Arrow up symbol
    let arrowConfig = NSImage.SymbolConfiguration(pointSize: 110 * scale, weight: .bold)
    if let arrowImage = NSImage(systemSymbolName: "arrow.up", accessibilityDescription: nil)?
        .withSymbolConfiguration(arrowConfig) {

        let arrowSize = arrowImage.size
        let arrowRect = CGRect(
            x: badgeCenterX - arrowSize.width / 2,
            y: badgeCenterY - arrowSize.height / 2,
            width: arrowSize.width,
            height: arrowSize.height
        )

        // Tint white
        let tinted = NSImage(size: arrowImage.size)
        tinted.lockFocus()
        NSColor.white.set()
        let tintRect = NSRect(origin: .zero, size: arrowImage.size)
        arrowImage.draw(in: tintRect)
        tintRect.fill(using: .sourceAtop)
        tinted.unlockFocus()

        tinted.draw(in: arrowRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }
    ctx.restoreGState()

    image.unlockFocus()
    return image
}

// MARK: - Icon Generation

func generateIconSet() {
    // Create iconset directory
    let fm = FileManager.default
    try? fm.removeItem(atPath: outputDir)
    try! fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

    // Required sizes for macOS .iconset (filename → pixel size)
    let sizes: [(String, Int)] = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]

    print("Generating icon set...")

    for (filename, pixelSize) in sizes {
        let image = drawIcon(size: CGFloat(pixelSize))
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            fatalError("Failed to generate PNG for \(filename)")
        }
        let path = "\(outputDir)/\(filename)"
        try! pngData.write(to: URL(fileURLWithPath: path))
        print("  \(filename) (\(pixelSize)x\(pixelSize))")
    }

    // Convert to icns
    print("Converting to .icns...")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", outputDir, "-o", icnsOutput]
    try! process.run()
    process.waitUntilExit()

    if process.terminationStatus == 0 {
        print("Success! Icon saved to \(icnsOutput)")
        // Clean up iconset directory
        try? fm.removeItem(atPath: outputDir)
    } else {
        print("Error: iconutil failed with exit code \(process.terminationStatus)")
        exit(1)
    }
}

// MARK: - Main

generateIconSet()
