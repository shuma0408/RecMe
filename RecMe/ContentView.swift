//
//  ContentView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var scriptText: String = "ここにスクリプトを入力してください。\n\nこのテキストは自動的にスクロールして流れていきます。\n\nカメラを見ながら自然にスクリプトを読むことができます。\n\nテレプロンプターのように、スクリプトが上から下へ流れていくので、\n\n視線をカメラに向けたまま、スクリプトを読むことができます。\n\nスクロール速度は調整可能です。"
    @State private var scrollSpeed: Double = 50.0
    @State private var timeLimit: TimeInterval? = nil
    @State private var isRecording: Bool = false
    @State private var selectedTab: Int = 0  // 0 = 録画, 1 = スクリプト台本
    @State private var showSettings: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 録画ページ（左、デフォルト）
            RecordingView(
                cameraManager: cameraManager,
                scriptText: scriptText,
                scrollSpeed: scrollSpeed,
                timeLimit: timeLimit,
                isRecording: $isRecording
            )
            .tabItem {
                Label("録画", systemImage: "video.circle.fill")
            }
            .tag(0)
            
            // スクリプト台本ページ（右）
            ScriptEditView(
                scriptText: $scriptText,
                scrollSpeed: $scrollSpeed,
                timeLimit: $timeLimit
            )
            .tabItem {
                Label("スクリプト台本", systemImage: "text.cursor")
            }
            .tag(1)
            
            // 設定ページ
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.primaryColor) // タブバーのアクセントカラー
        .onAppear {
            cameraManager.setupCamera()
        }
    }
}

#Preview {
    ContentView()
}
