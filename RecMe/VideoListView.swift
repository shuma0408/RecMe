//
//  VideoListView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI
import AVKit
import Photos

struct VideoListView: View {
    @State private var videos: [VideoItem] = []
    @State private var selectedVideo: VideoItem?
    @State private var selectedPreset: ExportPreset = .mynavi
    @State private var isExporting: Bool = false
    @Environment(\.dismiss) var dismiss
    
    // Photos app style grid: 3 columns, 1pt spacing
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    if videos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(Color(.systemGray4))
                            Text("写真やビデオがありません")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 1) {
                                ForEach(videos) { video in
                                    VideoGridItem(video: video)
                                        .frame(height: geometry.size.width / 3) // Make it square
                                        .onTapGesture {
                                            selectedVideo = video
                                        }
                                }
                            }
                            .padding(.bottom, 20) // Add some bottom padding
                        }
                    }
                }
            }
            .navigationTitle("アルバム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                loadVideos()
            }
            .sheet(item: $selectedVideo) { video in
                VideoDetailView(
                    video: video,
                    selectedPreset: $selectedPreset,
                    isExporting: $isExporting,
                    onDelete: {
                        deleteVideo(video)
                        selectedVideo = nil
                        loadVideos()
                    }
                )
            }
            .onChange(of: selectedVideo) { newValue in
                if newValue == nil {
                    loadVideos()
                }
            }
        }
    }
    
    private func loadVideos() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: [.creationDateKey], options: [])
            videos = files
                .filter { $0.pathExtension == "mov" || $0.pathExtension == "mp4" }
                .map { url in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let size = attributes?[.size] as? Int64 ?? 0
                    let date = (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
                    return VideoItem(url: url, size: size, date: date)
                }
                .sorted { $0.date > $1.date } // Keep newest first for convenience, even if Photos is bottom-heavy
        } catch {
            print("ビデオの読み込みエラー: \(error)")
        }
    }
    
    private func deleteVideo(_ video: VideoItem) {
        try? FileManager.default.removeItem(at: video.url)
        loadVideos()
    }
}

struct VideoItem: Identifiable, Equatable {
    let id: String
    let url: URL
    let size: Int64
    let date: Date
    
    init(url: URL, size: Int64, date: Date) {
        self.url = url
        self.size = size
        self.date = date
        self.id = url.absoluteString
    }
    
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct VideoGridItem: View {
    let video: VideoItem
    @State private var thumbnail: UIImage?
    @State private var videoDuration: TimeInterval?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Thumbnail
            GeometryReader { geo in
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color(.systemGray5)
                        .overlay(
                            Image(systemName: "video")
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Duration overlay (Photos style)
            if let duration = videoDuration {
                Text(formatDuration(duration))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1) // Text shadow for visibility
                    .padding(4)
            }
        }
        .contentShape(Rectangle()) // Ensure tap target covers entire cell
        .onAppear {
            if thumbnail == nil { loadThumbnail() }
            if videoDuration == nil { loadDuration() }
        }
    }
    
    private func loadThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: video.url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 300, height: 300)
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("サムネイル生成エラー: \(error)")
            }
        }
    }
    
    private func loadDuration() {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: video.url)
            let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : nil
            DispatchQueue.main.async {
                self.videoDuration = duration
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Keeping VideoDetailView generally as is, but could be polished further.
// Included here to ensure the file compiles complete.
struct VideoDetailView: View {
    let video: VideoItem
    @Binding var selectedPreset: ExportPreset
    @Binding var isExporting: Bool
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer?
    @State private var showShareSheet: Bool = false
    @State private var exportedURL: URL?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fit) // Ensure aspect ratio is respected
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .onAppear {
                            player.play()
                        }
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                }
                
                // Controls
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Metadata
                        HStack {
                            VStack(alignment: .leading) {
                                Text(formatDate(video.date))
                                    .font(.headline)
                                Text(formatFileSize(video.size))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.top)
                        
                        Divider()
                        
                        // Export Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("提出用書き出し")
                                .font(.headline)
                            
                            Picker("プリセット", selection: $selectedPreset) {
                                ForEach(ExportPreset.allCases) { preset in
                                    Text("\(preset.rawValue) (max \(preset.maxFileSizeMB)MB)").tag(preset)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Button(action: { exportVideo() }) {
                                HStack {
                                    if isExporting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    Text(isExporting ? "書き出し中..." : "書き出し")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isExporting ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isExporting)
                        }
                        
                        if let exportedURL = exportedURL {
                            Button(action: { showShareSheet = true }) {
                                Label("共有する", systemImage: "square.and.arrow.up")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .sheet(isPresented: $showShareSheet) {
                                ShareSheet(items: [exportedURL])
                            }
                        }
                        
                        Divider()
                        
                        // Danger Zone
                        Button(action: { showDeleteAlert = true }) {
                            Label("このビデオを削除", systemImage: "trash")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert("動画を削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("この操作は取り消せません。")
            }
            .onAppear {
                player = AVPlayer(url: video.url)
            }
        }
    }
    
    private func exportVideo() {
        isExporting = true
        VideoExportManager.shared.exportVideo(inputURL: video.url, preset: selectedPreset) { result in
            DispatchQueue.main.async {
                isExporting = false
                switch result {
                case .success(let url):
                    exportedURL = url
                case .failure(let error):
                    print("エクスポートエラー: \(error)")
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
