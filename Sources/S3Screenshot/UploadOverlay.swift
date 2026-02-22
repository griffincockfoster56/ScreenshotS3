import Cocoa
import SwiftUI

// MARK: - State

enum OverlayState {
    case uploading
    case success(url: String)
    case error(message: String)
}

// MARK: - ViewModel

class OverlayViewModel: ObservableObject {
    @Published var state: OverlayState = .uploading
    @Published var isVisible: Bool = false
}

// MARK: - Overlay Controller

class UploadOverlay {
    private var panel: NSPanel?
    private let viewModel = OverlayViewModel()
    private var dismissWork: DispatchWorkItem?
    private var uploadingShownAt: Date?
    private var pendingState: OverlayState?
    private static let minUploadingDuration: TimeInterval = 0.8

    func showUploading() {
        uploadingShownAt = Date()
        pendingState = nil
        applyState(.uploading)
    }

    func showSuccess(url: String) {
        transitionFromUploading(to: .success(url: url))
    }

    func showError(message: String) {
        transitionFromUploading(to: .error(message: message))
    }

    /// Ensures the uploading state is visible for at least minUploadingDuration
    private func transitionFromUploading(to state: OverlayState) {
        guard let shownAt = uploadingShownAt else {
            applyState(state)
            return
        }

        let elapsed = Date().timeIntervalSince(shownAt)
        let remaining = Self.minUploadingDuration - elapsed

        if remaining <= 0 {
            applyState(state)
        } else {
            pendingState = state
            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
                guard let self, let pending = self.pendingState else { return }
                self.pendingState = nil
                self.applyState(pending)
            }
        }
    }

    private func applyState(_ state: OverlayState) {
        dismissWork?.cancel()
        dismissWork = nil

        viewModel.state = state
        viewModel.isVisible = true

        if panel == nil {
            createPanel()
        }
        panel?.orderFront(nil)

        // Auto-dismiss for terminal states
        switch state {
        case .uploading:
            break
        case .success, .error:
            uploadingShownAt = nil
            let work = DispatchWorkItem { [weak self] in
                self?.dismiss()
            }
            dismissWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: work)
        }
    }

    private func dismiss() {
        viewModel.isVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.panel?.orderOut(nil)
        }
    }

    private func createPanel() {
        let contentView = OverlayContentView(viewModel: viewModel)

        let p = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false
        p.ignoresMouseEvents = false
        p.hidesOnDeactivate = false
        p.contentView = NSHostingView(rootView: contentView)

        if let screen = NSScreen.main {
            let x = screen.frame.midX - 190
            let y = screen.frame.maxY - 170
            p.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel = p
    }
}

// MARK: - SwiftUI View

private struct OverlayContentView: View {
    @ObservedObject var viewModel: OverlayViewModel

    @State private var appeared = false
    @State private var iconBounce = false
    @State private var shimmer = false
    @State private var spinAngle: Double = 0
    @State private var arrowPulse = false
    @State private var copied = false

    private var accentColors: (primary: Color, secondary: Color) {
        switch viewModel.state {
        case .uploading:
            return (Color(hex: "667eea"), Color(hex: "764ba2"))
        case .success:
            return (Color(hex: "34d399"), Color(hex: "059669"))
        case .error:
            return (Color(hex: "f87171"), Color(hex: "dc2626"))
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            iconView
            textView
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(backgroundView)
        .shadow(color: accentColors.primary.opacity(0.25), radius: 30, y: 8)
        .scaleEffect(viewModel.isVisible ? 1.0 : 0.7)
        .opacity(viewModel.isVisible ? 1.0 : 0)
        .offset(y: viewModel.isVisible ? 0 : -20)
        .frame(width: 380)
        .animation(.spring(response: 0.5, dampingFraction: 0.65), value: viewModel.isVisible)
        .onChange(of: stateKey) { _ in
            onStateChange()
        }
        .onAppear {
            viewModel.isVisible = true
            onStateChange()
        }
    }

    // Stable key for detecting state changes
    private var stateKey: String {
        switch viewModel.state {
        case .uploading: return "uploading"
        case .success(let url): return "success:\(url)"
        case .error(let msg): return "error:\(msg)"
        }
    }

    // MARK: - Icon

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            switch viewModel.state {
            case .uploading:
                // Spinning gradient ring
                Circle()
                    .trim(from: 0.05, to: 0.8)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(hex: "667eea").opacity(0.1),
                                Color(hex: "667eea"),
                                Color(hex: "764ba2"),
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .frame(width: 42, height: 42)
                    .rotationEffect(.degrees(spinAngle))

                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(arrowPulse ? 1.1 : 0.9)

            case .success:
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "34d399"), Color(hex: "059669")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(iconBounce ? 1.0 : 0.3)

            case .error:
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f87171"), Color(hex: "dc2626")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(iconBounce ? 1.0 : 0.3)
            }
        }
    }

    // MARK: - Text + Button

    @ViewBuilder
    private var textView: some View {
        switch viewModel.state {
        case .uploading:
            VStack(alignment: .leading, spacing: 3) {
                Text("Uploading Screenshot...")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(.white)
                Text("This will only take a moment")
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(.white.opacity(0.45))
            }

        case .success(let url):
            VStack(alignment: .leading, spacing: 8) {
                Text("Screenshot Uploaded!")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(.white)

                HStack(spacing: 10) {
                    Text(truncateURL(url))
                        .font(.custom("Inter", size: 11))
                        .foregroundColor(.white.opacity(0.45))
                        .lineLimit(1)

                    Button(action: copyLink) {
                        HStack(spacing: 5) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 10, weight: .semibold))
                            Text(copied ? "Copied!" : "Copy Link")
                                .font(.custom("Inter-SemiBold", size: 11))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(
                                copied
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
                    }
                    .buttonStyle(.plain)
                }
            }

        case .error(let message):
            VStack(alignment: .leading, spacing: 3) {
                Text("Upload Failed")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(.white)
                Text(message)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(2)
            }
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0d0d24"), Color(hex: "151535"), Color(hex: "0d0d24")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.06), .clear],
                        startPoint: shimmer ? .trailing : .leading,
                        endPoint: shimmer ? .leading : .trailing
                    )
                )

            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            accentColors.primary.opacity(0.3),
                            Color.white.opacity(0.08),
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Actions

    private func copyLink() {
        if case .success(let url) = viewModel.state {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url, forType: .string)
            withAnimation(.easeInOut(duration: 0.2)) { copied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.2)) { copied = false }
            }
        }
    }

    private func truncateURL(_ url: String) -> String {
        guard url.count > 34 else { return url }
        let start = url.prefix(20)
        let end = url.suffix(12)
        return "\(start)...\(end)"
    }

    // MARK: - State Transitions

    private func onStateChange() {
        // Reset animation states
        iconBounce = false
        shimmer = false
        copied = false

        switch viewModel.state {
        case .uploading:
            // Continuous spinner
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                spinAngle = 360
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                arrowPulse = true
            }

        case .success, .error:
            // Stop spinner
            spinAngle = 0
            arrowPulse = false

            // Icon bounce in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.5).delay(0.1)) {
                iconBounce = true
            }
            // Shimmer sweep
            withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                shimmer = true
            }
        }
    }
}
