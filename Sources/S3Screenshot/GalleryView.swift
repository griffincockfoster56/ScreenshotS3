import AppKit
import SwiftUI

// MARK: - ViewModel

class GalleryViewModel: ObservableObject {
    @Published var objects: [S3Object] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = false

    private var continuationToken: String?
    private let uploader = S3Uploader()

    func loadInitial() {
        objects = []
        continuationToken = nil
        hasMore = false
        loadPage()
    }

    func loadMore() {
        guard hasMore, !isLoading else { return }
        loadPage()
    }

    private func loadPage() {
        let settings = SettingsManager.shared
        guard let accessKey = settings.accessKeyId,
              let secretKey = settings.secretAccessKey,
              let region = settings.region,
              let bucket = settings.bucketName
        else {
            errorMessage = "AWS credentials not configured"
            return
        }

        isLoading = true
        errorMessage = nil

        uploader.listObjects(
            bucket: bucket, accessKey: accessKey, secretKey: secretKey,
            region: region, continuationToken: continuationToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let listResult):
                    let sorted = listResult.objects.sorted { $0.lastModified > $1.lastModified }
                    self.objects.append(contentsOf: sorted)
                    self.continuationToken = listResult.continuationToken
                    self.hasMore = listResult.continuationToken != nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func publicURL(for object: S3Object) -> String {
        let settings = SettingsManager.shared
        let bucket = settings.bucketName ?? ""
        let region = settings.region ?? "us-east-1"
        let encodedKey = object.key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? object.key
        return "https://\(bucket).s3.\(region).amazonaws.com/\(encodedKey)"
    }
}

// MARK: - Gallery View

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @State private var appeared = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

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

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.1), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                content
            }
        }
        .frame(minWidth: 520, minHeight: 400)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appeared = true }
            viewModel.loadInitial()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Gallery")
                    .font(.custom("Inter-Bold", size: 28))
                    .foregroundColor(.white)

                if !viewModel.objects.isEmpty {
                    Text("\(viewModel.objects.count) screenshot\(viewModel.objects.count == 1 ? "" : "s")")
                        .font(.custom("Inter", size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            Spacer()

            Button(action: { viewModel.loadInitial() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.objects.isEmpty {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Loading screenshots...")
                    .font(.custom("Inter", size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        } else if let error = viewModel.errorMessage, viewModel.objects.isEmpty {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "f87171"))
                Text(error)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button("Retry") { viewModel.loadInitial() }
                    .buttonStyle(.plain)
                    .font(.custom("Inter-SemiBold", size: 13))
                    .foregroundColor(Color(hex: "667eea"))
                    .padding(.top, 4)
            }
            Spacer()
        } else if viewModel.objects.isEmpty {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.15))
                Text("No screenshots yet")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white.opacity(0.4))
                Text("Take a screenshot and it will appear here")
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(.white.opacity(0.25))
            }
            Spacer()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.objects, id: \.key) { object in
                        GalleryThumbnail(
                            object: object,
                            url: viewModel.publicURL(for: object)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                if viewModel.hasMore {
                    Button(action: { viewModel.loadMore() }) {
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .frame(width: 14, height: 14)
                                Text("Loading...")
                                    .font(.custom("Inter-SemiBold", size: 13))
                            } else {
                                Text("Load More")
                                    .font(.custom("Inter-SemiBold", size: 13))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                        }
                        .foregroundColor(Color(hex: "667eea"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "667eea").opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "667eea").opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                Spacer(minLength: 16)
            }
        }
    }
}

// MARK: - Thumbnail

private struct GalleryThumbnail: View {
    let object: S3Object
    let url: String

    @State private var isHovered = false
    @State private var copied = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.white.opacity(0.03))
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.15))
                            )
                    default:
                        Rectangle()
                            .fill(Color.white.opacity(0.03))
                            .frame(height: 120)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.6)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()

                // Action buttons on hover
                if isHovered {
                    HStack(spacing: 6) {
                        actionButton(
                            icon: copied ? "checkmark" : "doc.on.doc",
                            color: copied ? Color(hex: "34d399") : .white
                        ) {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(url, forType: .string)
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                copied = false
                            }
                        }

                        actionButton(icon: "safari", color: .white) {
                            if let linkURL = URL(string: url) {
                                NSWorkspace.shared.open(linkURL)
                            }
                        }
                    }
                    .padding(8)
                    .transition(.opacity)
                }
            }

            // Info section
            VStack(alignment: .leading, spacing: 4) {
                Text(object.key.components(separatedBy: "/").last ?? object.key)
                    .font(.custom("Inter-SemiBold", size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(Self.dateFormatter.string(from: object.lastModified))
                    .font(.custom("Inter", size: 10))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovered ? 0.1 : 0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isHovered ? 0.2 : 0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { h in
            withAnimation(.easeInOut(duration: 0.2)) { isHovered = h }
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color.opacity(0.9))
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.black.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
