import AppKit
import ServiceManagement
import SwiftUI

// MARK: - Hex Color

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

// MARK: - Logo

private struct LogoView: View {
    @State private var appeared = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .blur(radius: glowPulse ? 30 : 22)
                .opacity(glowPulse ? 0.7 : 0.45)

            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            ZStack {
                // Bucket handle
                Path { p in
                    p.addArc(
                        center: CGPoint(x: 25, y: 16),
                        radius: 11,
                        startAngle: .degrees(-195),
                        endAngle: .degrees(-345),
                        clockwise: true
                    )
                }
                .stroke(Color.white.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 50, height: 50)

                // Person (upper body emerging from bucket)
                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .offset(y: -5)

                // Bucket body (trapezoid)
                Path { p in
                    p.move(to: CGPoint(x: 4, y: 0))
                    p.addLine(to: CGPoint(x: 46, y: 0))
                    p.addLine(to: CGPoint(x: 42, y: 22))
                    p.addQuadCurve(
                        to: CGPoint(x: 8, y: 22),
                        control: CGPoint(x: 25, y: 26)
                    )
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.2))
                .frame(width: 50, height: 26)
                .offset(y: 10)

                // Bucket rim
                Capsule()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 44, height: 5)
                    .offset(y: 0)

                // Upload badge
                ZStack {
                    Circle().fill(Color(hex: "34d399")).frame(width: 22, height: 22)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 24, y: -24)
            }
        }
        .scaleEffect(appeared ? 1.0 : 0.5)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Glass Text Field

private struct GlassTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 20)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.25))
                        .font(.custom("Inter", size: 14))
                }
                if isSecure {
                    SecureField("", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .font(.custom("Inter", size: 14))
                } else {
                    TextField("", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .font(.custom("Inter", size: 14))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovered ? 0.12 : 0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isHovered ? 0.25 : 0.08), lineWidth: 1)
        )
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { isHovered = h } }
    }
}

// MARK: - Glass Region Picker

private struct GlassRegionPicker: View {
    @Binding var selection: String
    let regions: [String]
    @State private var isHovered = false

    var body: some View {
        Menu {
            ForEach(regions, id: \.self) { region in
                Button(action: { selection = region }) {
                    HStack {
                        Text(region)
                        if region == selection { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 20)
                Text(selection)
                    .foregroundColor(.white)
                    .font(.custom("Inter", size: 14))
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isHovered ? 0.12 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isHovered ? 0.25 : 0.08), lineWidth: 1)
            )
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { isHovered = h } }
    }
}

// MARK: - Glass Bucket Picker (existing buckets)

private struct GlassBucketPicker: View {
    @Binding var selection: String
    let buckets: [String]
    @State private var isHovered = false

    var body: some View {
        Menu {
            ForEach(buckets, id: \.self) { bucket in
                Button(action: { selection = bucket }) {
                    HStack {
                        Text(bucket)
                        if bucket == selection { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 20)
                if selection.isEmpty {
                    Text("Select a bucket")
                        .foregroundColor(.white.opacity(0.25))
                        .font(.custom("Inter", size: 14))
                } else {
                    Text(selection)
                        .foregroundColor(.white)
                        .font(.custom("Inter", size: 14))
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isHovered ? 0.12 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isHovered ? 0.25 : 0.08), lineWidth: 1)
            )
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .menuIndicator(.hidden)
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { isHovered = h } }
    }
}

// MARK: - Segment Picker

private struct GlassSegment: View {
    @Binding var selection: Int
    let labels: [String]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(labels.indices, id: \.self) { i in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selection = i }
                }) {
                    Text(labels[i])
                        .font(.custom("Inter", size: 13))
                        .foregroundColor(selection == i ? .white : .white.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .fill(Color.white.opacity(selection == i ? 0.14 : 0))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 11)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Instructions Card

private struct InstructionsCard: View {
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "667eea"))

                    Text("New to AWS? Here's how to get started")
                        .font(.custom("Inter-Medium", size: 12.5))
                        .foregroundColor(.white.opacity(0.6))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.25))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    stepRow(1, "Go to ", "aws.amazon.com", " and create a free account")
                    stepRow(2, "Search ", "IAM", " in the AWS console and open it")
                    stepRow(3, "Click ", "Users", " in the sidebar, then ", "Create User")
                    stepRow(4, "Attach the ", "AmazonS3FullAccess", " policy to the user")
                    stepRow(5, "Open the user, go to ", "Security Credentials", "")
                    stepRow(6, "Click ", "Create Access Key", ", pick ", "Third-party service")
                    stepRow(7, "Copy your ", "Access Key ID", " and ", "Secret Access Key", " below")
                }
                .padding(.top, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func stepRow(_ num: Int, _ parts: String...) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(num)")
                .font(.custom("Inter-Bold", size: 10))
                .foregroundColor(Color(hex: "667eea"))
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color(hex: "667eea").opacity(0.15)))

            buildStepText(parts)
                .font(.custom("Inter", size: 12))
                .lineSpacing(3)
        }
    }

    private func buildStepText(_ parts: [String]) -> Text {
        var result = Text("")
        for (i, part) in parts.enumerated() {
            if i % 2 == 0 {
                result = result + Text(part).foregroundColor(.white.opacity(0.45))
            } else {
                result = result + Text(part).foregroundColor(Color(hex: "93a3f8")).bold()
            }
        }
        return result
    }
}

// MARK: - Section Label

private struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.custom("Inter-SemiBold", size: 10.5))
            .foregroundColor(.white.opacity(0.25))
            .tracking(1.2)
            .padding(.top, 6)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var accessKeyId = ""
    @State private var secretAccessKey = ""
    @State private var region = "us-east-1"
    @State private var bucketMode = 0 // 0 = create new, 1 = use existing
    @State private var newBucketName = "screenshots-\(UUID().uuidString.prefix(12).lowercased())"
    @State private var existingBuckets: [String] = []
    @State private var selectedBucket = ""
    @State private var isLoadingBuckets = false
    @State private var instructionsExpanded = false
    @State private var appeared = false
    @State private var showSuccess = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var buttonHovered = false
    @State private var launchAtLogin = true

    var onSave: (() -> Void)?

    private let uploader = S3Uploader()

    private let regions = [
        "us-east-1", "us-east-2", "us-west-1", "us-west-2",
        "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1",
        "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-northeast-2",
        "sa-east-1", "ca-central-1",
    ]

    private var bgGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "06060f"),
                Color(hex: "0d0d24"),
                Color(hex: "151535"),
                Color(hex: "0d0d24"),
                Color(hex: "06060f"),
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            bgGradient.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        LogoView().padding(.top, 20)

                        Text("ScreenshotS3")
                            .font(.custom("Inter-Bold", size: 28))
                            .foregroundColor(.white)
                            .padding(.top, 22)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                        Text("Instantly upload screenshots to the cloud")
                            .font(.custom("Inter", size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 6)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color.white.opacity(0.1), .clear],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.vertical, 22)
                            .opacity(appeared ? 1 : 0)
                    }

                    // Credentials
                    SectionLabel(text: "AWS Credentials")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(appeared ? 1 : 0)

                    VStack(spacing: 12) {
                        animatedField(index: 0) {
                            GlassTextField(
                                icon: "key.fill",
                                placeholder: "AWS Access Key ID",
                                text: $accessKeyId
                            )
                        }
                        animatedField(index: 1) {
                            GlassTextField(
                                icon: "lock.fill",
                                placeholder: "AWS Secret Access Key",
                                text: $secretAccessKey,
                                isSecure: true
                            )
                        }
                        animatedField(index: 2) {
                            GlassRegionPicker(selection: $region, regions: regions)
                        }
                    }
                    .padding(.top, 8)

                    // Bucket + error + save
                    VStack(spacing: 0) {
                        SectionLabel(text: "S3 Bucket")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                            .opacity(appeared ? 1 : 0)

                        VStack(spacing: 12) {
                            animatedField(index: 3) {
                                GlassSegment(
                                    selection: $bucketMode,
                                    labels: ["Create new bucket", "Use existing bucket"]
                                )
                            }

                            animatedField(index: 4) {
                                bucketField
                            }
                        }
                        .padding(.top, 8)

                        if let msg = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11))
                                Text(msg)
                                    .font(.custom("Inter", size: 12))
                            }
                            .foregroundColor(Color(hex: "f87171"))
                            .padding(.top, 14)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Launch at login toggle
                        animatedField(index: 5) {
                            HStack(spacing: 12) {
                                Image(systemName: "sunrise.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                                    .frame(width: 20)

                                Text("Launch at login")
                                    .font(.custom("Inter", size: 14))
                                    .foregroundColor(.white)

                                Spacer()

                                Toggle("", isOn: $launchAtLogin)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .onChange(of: launchAtLogin) { newValue in
                                        SettingsManager.shared.launchAtLogin = newValue
                                        if newValue {
                                            try? SMAppService.mainApp.register()
                                        } else {
                                            try? SMAppService.mainApp.unregister()
                                        }
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .padding(.top, 16)

                        Spacer(minLength: 24)

                        saveButton

                        Text("Every time you take a screenshot, it will be uploaded to your S3 bucket and the link will be copied to your clipboard.")
                            .font(.custom("Inter", size: 11.5))
                            .foregroundColor(.white.opacity(0.25))
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)
                            .padding(.horizontal, 12)
                            .opacity(appeared ? 1 : 0)
                    }

                    // Pro tips card
                    animatedField(index: 6) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "f4c542"))
                                Text("Pro Tips")
                                    .font(.custom("Inter-SemiBold", size: 12.5))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Text("Cmd+G")
                                        .font(.custom("Inter-SemiBold", size: 11))
                                        .foregroundColor(Color(hex: "93a3f8"))
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color(hex: "667eea").opacity(0.15))
                                        )
                                    Text("Open the Gallery to browse past uploads")
                                        .font(.custom("Inter", size: 12))
                                        .foregroundColor(.white.opacity(0.45))
                                }
                                HStack(spacing: 8) {
                                    Text("Cmd+,")
                                        .font(.custom("Inter-SemiBold", size: 11))
                                        .foregroundColor(Color(hex: "93a3f8"))
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color(hex: "667eea").opacity(0.15))
                                        )
                                    Text("Open Settings from the menu bar")
                                        .font(.custom("Inter", size: 12))
                                        .foregroundColor(.white.opacity(0.45))
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.top, 16)

                    // Help section at bottom
                    animatedField(index: 7) {
                        InstructionsCard(isExpanded: $instructionsExpanded)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 24)
            }
        }
        .frame(width: 520, height: 740)
        .onAppear {
            loadSettings()
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appeared = true }
        }
        .onChange(of: bucketMode) { newValue in
            errorMessage = nil
            if newValue == 1 && existingBuckets.isEmpty && hasCredentials {
                fetchBuckets()
            }
        }
    }

    // MARK: - Bucket Field

    @ViewBuilder
    private var bucketField: some View {
        if bucketMode == 0 {
            GlassTextField(
                icon: "externaldrive.fill",
                placeholder: "screenshots",
                text: $newBucketName
            )
        } else {
            if isLoadingBuckets {
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.65)
                        .frame(width: 16, height: 16)
                    Text("Loading buckets...")
                        .font(.custom("Inter", size: 13))
                        .foregroundColor(.white.opacity(0.35))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            } else if existingBuckets.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.3))
                    Text(hasCredentials ? "No buckets found — enter valid credentials" : "Enter credentials above first")
                        .font(.custom("Inter", size: 13))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    if hasCredentials {
                        Button(action: fetchBuckets) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "667eea"))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            } else {
                GlassBucketPicker(selection: $selectedBucket, buckets: existingBuckets)
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: save) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 16, height: 16)
                    Text("Creating bucket...")
                        .font(.custom("Inter-SemiBold", size: 15))
                } else if showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Saved!")
                        .font(.custom("Inter-SemiBold", size: 15))
                } else {
                    Text("Save & Start")
                        .font(.custom("Inter-SemiBold", size: 15))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        showSuccess
                            ? LinearGradient(
                                colors: [Color(hex: "34d399"), Color(hex: "059669")],
                                startPoint: .leading, endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading, endPoint: .trailing
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(
                color: Color(hex: "667eea").opacity(buttonHovered ? 0.5 : 0.2),
                radius: buttonHovered ? 20 : 10, y: 4
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(buttonHovered ? 1.025 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: buttonHovered)
        .onHover { buttonHovered = $0 }
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.45)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.55), value: appeared)
    }

    // MARK: - Logic

    private var hasCredentials: Bool {
        !accessKeyId.isEmpty && !secretAccessKey.isEmpty
    }

    private var canSave: Bool {
        guard hasCredentials && !isSaving else { return false }
        if bucketMode == 0 { return !newBucketName.isEmpty }
        return !selectedBucket.isEmpty
    }

    @ViewBuilder
    private func animatedField<Content: View>(
        index: Int, @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .easeOut(duration: 0.45).delay(0.2 + Double(index + 1) * 0.06),
                value: appeared
            )
    }

    private func loadSettings() {
        let s = SettingsManager.shared
        accessKeyId = s.accessKeyId ?? ""
        secretAccessKey = s.secretAccessKey ?? ""
        region = s.region ?? "us-east-1"
        if let saved = s.bucketName, !saved.isEmpty {
            newBucketName = saved
        }
        launchAtLogin = s.launchAtLogin
    }

    private func fetchBuckets() {
        guard hasCredentials else { return }
        isLoadingBuckets = true
        errorMessage = nil

        uploader.listBuckets(
            accessKey: accessKeyId, secretKey: secretAccessKey, region: region
        ) { result in
            DispatchQueue.main.async {
                isLoadingBuckets = false
                switch result {
                case .success(let buckets):
                    existingBuckets = buckets
                    if let first = buckets.first, selectedBucket.isEmpty {
                        selectedBucket = first
                    }
                case .failure(let error):
                    withAnimation { errorMessage = error.localizedDescription }
                }
            }
        }
    }

    private func save() {
        errorMessage = nil
        let s = SettingsManager.shared
        s.accessKeyId = accessKeyId
        s.secretAccessKey = secretAccessKey
        s.region = region

        let chosenBucket = bucketMode == 0 ? newBucketName : selectedBucket

        if bucketMode == 0 {
            isSaving = true
            uploader.createBucket(
                name: chosenBucket, accessKey: accessKeyId,
                secretKey: secretAccessKey, region: region
            ) { result in
                switch result {
                case .success:
                    // Make the bucket publicly accessible
                    uploader.makeBucketPublic(
                        bucket: chosenBucket, accessKey: accessKeyId,
                        secretKey: secretAccessKey, region: region
                    ) { publicResult in
                        DispatchQueue.main.async {
                            isSaving = false
                            switch publicResult {
                            case .success:
                                s.bucketName = chosenBucket
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showSuccess = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onSave?() }
                            case .failure(let error):
                                // Bucket was created but public access failed — save anyway and warn
                                s.bucketName = chosenBucket
                                withAnimation { errorMessage = "Bucket created, but public access setup failed: \(error.localizedDescription). Uploads may not be publicly accessible." }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showSuccess = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onSave?() }
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        isSaving = false
                        withAnimation { errorMessage = error.localizedDescription }
                    }
                }
            }
        } else {
            isSaving = true
            uploader.makeBucketPublic(
                bucket: chosenBucket, accessKey: accessKeyId,
                secretKey: secretAccessKey, region: region
            ) { result in
                DispatchQueue.main.async {
                    isSaving = false
                    s.bucketName = chosenBucket
                    if case .failure(let error) = result {
                        withAnimation { errorMessage = "Public access setup failed: \(error.localizedDescription). Uploads may not be publicly accessible." }
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onSave?() }
                }
            }
        }
    }
}
