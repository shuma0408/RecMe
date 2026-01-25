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
    let scrollSpeed: Double
    let timeLimit: TimeInterval?
    @Binding var isRecording: Bool
    
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showVideoList: Bool = false
    
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
            
            // カメラ視線誘導枠（上部中央）
            if cameraManager.hasPermission {
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            Text("ここを見てください")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                        )
                                )
                        }
                        .padding(.top, 60)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            // 録画時間表示
            if isRecording, let limit = timeLimit {
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Text(formatTime(recordingTime))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                            
                            if recordingTime > limit {
                                Text("時間超過")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                            } else if recordingTime > limit * 0.9 {
                                Text("残りわずか")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 50)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
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
                    
                    // スペーサー（左右対称にするため）
                    Color.clear
                        .frame(width: 50, height: 50)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
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
        cameraManager.stopRecording()
        isRecording = false
        recordingTime = 0
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
    }
}
