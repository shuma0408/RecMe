//
//  ScriptEditView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct ScriptEditView: View {
    @StateObject private var scriptManager = ScriptManager()
    @Binding var scriptText: String
    @Binding var scrollSpeed: Double
    @Binding var timeLimit: TimeInterval?
    
    @State private var scriptTitle: String = "新しいスクリプト"
    @State private var useTimeLimit: Bool = false
    @State private var selectedMinutes: Int = 1
    @State private var selectedSeconds: Int = 0
    @State private var showScriptList: Bool = false
    @State private var showAIAssistant: Bool = false
    @State private var showSaveSuccess: Bool = false
    
    // 時間制限から計算されたスクロール速度
    private var calculatedScrollSpeed: Double {
        guard useTimeLimit, let limit = timeLimit, limit > 0 else {
            return scrollSpeed
        }
        // 原稿の長さ（行数×平均行高）を時間で割る
        let lines = scriptText.components(separatedBy: .newlines).count
        let estimatedHeight = Double(lines) * 50.0 // 1行あたり約50ピクセル
        return estimatedHeight / limit
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                // スクリプト選択・管理
                HStack(spacing: 12) {
                    Button(action: {
                        showScriptList = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("スクリプト一覧")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                    
                    // スクリプトタイトル
                    VStack(alignment: .leading, spacing: 8) {
                        Text("タイトル")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("スクリプトタイトルを入力", text: $scriptTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 0)
                    }
                    .padding(.horizontal)
                    
                    // スクリプト編集
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("スクリプト内容")
                                .font(.headline)
                            Spacer()
                            Text("\(scriptText.count)文字")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            ZStack(alignment: .topLeading) {
                                if scriptText.isEmpty {
                                    Text("スクリプトを入力してください...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                                TextEditor(text: $scriptText)
                                    .frame(minHeight: 200)
                                    .padding(4)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            
                            // AI生成ボタン（右側）
                            Button(action: {
                                showAIAssistant = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                    Text("AI生成")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .frame(width: 70)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // 時間制限設定
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $useTimeLimit) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("時間制限モード")
                                    .font(.headline)
                                Text("指定時間で自動的にスクロールします")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        if useTimeLimit {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("指定時間")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 20) {
                                    VStack(spacing: 8) {
                                        Text("分")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("分", selection: $selectedMinutes) {
                                            ForEach(0..<6) { minute in
                                                Text("\(minute)").tag(minute)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 80, height: 120)
                                        .clipped()
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("秒")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("秒", selection: $selectedSeconds) {
                                            ForEach(0..<60) { second in
                                                Text("\(second)").tag(second)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 80, height: 120)
                                        .clipped()
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("合計")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(selectedMinutes * 60 + selectedSeconds)秒")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.leading, 20)
                                }
                                .padding(.horizontal)
                                
                                let totalSeconds = Double(selectedMinutes * 60 + selectedSeconds)
                                if totalSeconds > 0 && !scriptText.isEmpty {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.blue)
                                        Text("自動スクロール速度: 約\(Int(calculatedScrollSpeed))px/秒")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                            .onChange(of: selectedMinutes) { _ in
                                updateTimeLimit()
                            }
                            .onChange(of: selectedSeconds) { _ in
                                updateTimeLimit()
                            }
                        } else {
                            // 手動速度設定
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("スクロール速度")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(scrollSpeed))")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                                
                                Slider(value: $scrollSpeed, in: 10...100, step: 1)
                                    .padding(.horizontal)
                                
                                HStack {
                                    Text("遅い")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("速い")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // 保存ボタン
                    Button(action: {
                        saveScript()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("スクリプトを保存")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(scriptTitle.isEmpty || scriptText.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(scriptTitle.isEmpty || scriptText.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("スクリプト台本")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showScriptList) {
                ScriptListView(scriptManager: scriptManager, scriptText: $scriptText, scriptTitle: $scriptTitle, timeLimit: $timeLimit, useTimeLimit: $useTimeLimit)
            }
            .sheet(isPresented: $showAIAssistant) {
                AIAssistantView(scriptText: $scriptText)
            }
            .onReceive(scriptManager.$selectedScript) { newValue in
                if let script = newValue {
                    scriptText = script.content
                    scriptTitle = script.title
                    timeLimit = script.timeLimit
                    useTimeLimit = script.timeLimit != nil
                    if let limit = script.timeLimit {
                        selectedMinutes = Int(limit) / 60
                        selectedSeconds = Int(limit) % 60
                    }
                }
            }
            .overlay(
                // 保存成功メッセージ
                Group {
                    if showSaveSuccess {
                        VStack {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("保存しました")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            Spacer()
                        }
                        .padding(.top, 100)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            )
        }
    }
    
    private func updateTimeLimit() {
        let totalSeconds = Double(selectedMinutes * 60 + selectedSeconds)
        timeLimit = totalSeconds > 0 ? totalSeconds : nil
    }
    
    private func saveScript() {
        guard !scriptTitle.isEmpty && !scriptText.isEmpty else {
            return
        }
        
        let totalSeconds = useTimeLimit ? Double(selectedMinutes * 60 + selectedSeconds) : nil
        let script = Script(title: scriptTitle, content: scriptText, timeLimit: totalSeconds)
        scriptManager.addScript(script)
        
        // 保存成功のフィードバック
        withAnimation {
            showSaveSuccess = true
        }
        
        // 2秒後に非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
}

