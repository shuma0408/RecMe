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
    @State private var showExportSheet: Bool = false
    @State private var selectedVideo: VideoItem?
    @State private var selectedPreset: ExportPreset = .mynavi
    @State private var isExporting: Bool = false
    @Environment(\.dismiss) var dismiss
    
    // グリッドレイアウトの列数（写真アプリ風）
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if videos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("録画された動画がありません")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(videos) { video in
                                VideoGridItem(video: video)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedVideo = video
                                    }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .refreshable {
                        loadVideos()
                    }
                }
            }
            .navigationTitle("録画一覧")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
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
                        // リストを再読み込み
                        loadVideos()
                    }
                )
            }
            .onChange(of: selectedVideo) { newValue in
                // ビデオ詳細が閉じられたときにリストを更新
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
                .sorted { $0.date > $1.date }
        } catch {
            print("ビデオの読み込みエラー: \(error)")
        }
    }
    
    private func deleteVideo(_ video: VideoItem) {
        try? FileManager.default.removeItem(at: video.url)
        loadVideos()
    }
    
    private func reloadVideos() {
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
        // URLをIDとして使用（一意性を保証）
        self.id = url.absoluteString
    }
    
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct VideoRow: View {
    let video: VideoItem
    
    var body: some View {
        HStack {
            // サムネイル
            VideoThumbnailView(url: video.url)
                .frame(width: 80, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.url.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(formatFileSize(video.size))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formatDate(video.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct VideoGridItem: View {
    let video: VideoItem
    @State private var thumbnail: UIImage?
    @State private var videoDuration: TimeInterval?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // サムネイル
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Color(.systemGray5)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            
            // 動画アイコンと時間
            HStack(spacing: 4) {
                Image(systemName: "play.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if let duration = videoDuration {
                    Text(formatDuration(duration))
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            .padding(6)
            .background(Color.black.opacity(0.6))
            .cornerRadius(4)
            .padding(4)
        }
        .onAppear {
            if thumbnail == nil {
                loadThumbnail()
            }
            if videoDuration == nil {
                loadDuration()
            }
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

struct VideoThumbnailView: View {
    let url: URL
    
    var body: some View {
        Group {
            if let thumbnail = generateThumbnail() {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray
            }
        }
    }
    
    private func generateThumbnail() -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}

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
            VStack(spacing: 20) {
                // ビデオプレーヤー
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .onAppear {
                            player.play()
                        }
                }
                
                // エクスポート設定
                VStack(alignment: .leading, spacing: 15) {
                    Text("提出形式を選択")
                        .font(.headline)
                    
                    Picker("プリセット", selection: $selectedPreset) {
                        ForEach(ExportPreset.allCases) { preset in
                            HStack {
                                Text(preset.rawValue)
                                Spacer()
                                Text("最大\(preset.maxFileSizeMB)MB")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button(action: {
                        exportVideo()
                    }) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isExporting ? "エクスポート中..." : "エクスポート")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isExporting ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(isExporting)
                    
                    if let exportedURL = exportedURL {
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Text("共有")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showShareSheet) {
                            ShareSheet(items: [exportedURL])
                        }
                    }
                    
                    // 削除ボタン
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("削除")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("ビデオ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("動画を削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("この動画を削除しますか？この操作は取り消せません。")
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
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
