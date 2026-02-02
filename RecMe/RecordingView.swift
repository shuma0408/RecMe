//
//  RecordingView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct RecordingView: View {
    @ObservedObject var cameraManager: CameraManager
    let scriptText: String
    let scriptTitle: String
    let scrollSpeed: Double
    let timeLimit: TimeInterval?
    @Binding var isRecording: Bool
    
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showVideoList: Bool = false
    @State private var selectedAspectRatio: AspectRatio = .original
    
    // 時間制限モードの場合の計算されたスクロール速度
    private var effectiveScrollSpeed: Double {
        if let limit = timeLimit, limit > 0 {
            let lines = scriptText.components(separatedBy: .newlines).count
            let estimatedHeight = Double(lines) * 50.0
            return estimatedHeight / limit
        }
        return scrollSpeed
    }
    
    var body: some View {
        ZStack {
            // カメラプレビュー（背景）
            if cameraManager.hasPermission {
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
            } else {
                // 権限がない場合のプレースホルダー
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("カメラの権限が必要です")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("設定アプリで権限を許可してください")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.top, 5)
                    Spacer()
                }
            }
            
            // スクリプト表示（画面全体、透明背景）
            if cameraManager.hasPermission {
                TeleprompterView(
                    text: scriptText,
                    scrollSpeed: effectiveScrollSpeed,
                    timeLimit: timeLimit,
                    isActive: isRecording
                )
                .ignoresSafeArea()
            }
            
            // アスペクト比ガイドマスク
            if cameraManager.hasPermission {
                GeometryReader { geometry in
                    let targetSize = calculateMaskSize(containerSize: geometry.size)
                    
                    // マスク描画（ターゲット領域外を暗くする）
                    ZStack {
                        Color.black.opacity(0.5)
                        
                        Rectangle()
                            .fill(Color.black) // Blend mode destination
                            .frame(width: targetSize.width, height: targetSize.height)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // タップを通過させる
                }

            }
            
            // ... (Other overlays like Teleprompter)
            
            // カメラ視線誘導枠（上部中央）
            if cameraManager.hasPermission {
                // ... (Existing code)
            }
            
            // 録画時間表示
            // ... (Existing code)
            
            // 録画コントロール（下部）
            VStack {
                Spacer()
                
                HStack(spacing: 30) {
                    // 動画一覧ボタン
                    Button(action: {
                        showVideoList = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .disabled(isRecording)
                    .opacity(isRecording ? 0.0 : 1.0) // 録画中は非表示/フェードアウト
                    
                    Spacer()
                    
                    // 録画ボタン
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color.white)
                                .frame(width: 70, height: 70)
                            
                            if isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                            } else {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .shadow(radius: 10)
                    }
                    .disabled(!cameraManager.hasPermission)
                    
                    Spacer()
                    
                    // アスペクト比変更ボタン
                    Menu {
                        ForEach(AspectRatio.allCases, id: \.self) { ratio in
                            Button(action: {
                                selectedAspectRatio = ratio
                            }) {
                                HStack {
                                    Text(ratio.rawValue)
                                    if selectedAspectRatio == ratio {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "aspectratio")
                                .font(.title2)
                            Text(selectedAspectRatio.shortName)
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                    }
                    .disabled(isRecording)
                    .opacity(isRecording ? 0.0 : 1.0) // 録画中は非表示/フェードアウト
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
// ...

        .onAppear {
            // 録画ページが表示されたときにカメラをセットアップ
            if !cameraManager.hasPermission {
                cameraManager.setupCamera()
            }
            // デバイスの向き通知を開始
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onDisappear {
            // デバイスの向き通知を停止
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // デバイスの向きが変わったときにプレビューを更新
            cameraManager.updateVideoOrientation()
        }
        .onChange(of: cameraManager.lastRecordedVideoURL) { newValue in
            if newValue != nil {
                // 録画完了後、ビデオ一覧を表示
                showVideoList = true
            }
        }
        .sheet(isPresented: $showVideoList) {
            VideoListView()
        }
    }
    
    private func startRecording() {
        // 録画開始時のバイブレーション
        HapticManager.shared.lightImpact()
        
        cameraManager.startRecording()
        isRecording = true
        recordingTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopRecording() {
        // 録画停止時のバイブレーション
        HapticManager.shared.mediumImpact()
        
        timer?.invalidate()
        timer = nil
        cameraManager.stopRecording(aspectRatio: selectedAspectRatio)
        isRecording = false
        recordingTime = 0
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
    }

    private func calculateMaskSize(containerSize: CGSize) -> CGSize {
        let width = containerSize.width
        let height = containerSize.height
        let ratio = selectedAspectRatio.ratio
        
        if ratio == 0 { return containerSize }
        
        if width / height > ratio {
            return CGSize(width: height * ratio, height: height)
        } else {
            return CGSize(width: width, height: width / ratio)
        }
    }
}


