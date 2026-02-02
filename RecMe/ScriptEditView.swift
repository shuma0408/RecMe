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
    
    @State private var scriptTitle: String = ""
    @State private var useTimeLimit: Bool = false
    @State private var selectedMinutes: Int = 1
    @State private var selectedSeconds: Int = 0
    @State private var showScriptList: Bool = false
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
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                VStack(spacing: 0) {
                    
                    // Main Content
                    List {
                        // Title Section
                        Section {
                            TextField("タイトルを入力", text: $scriptTitle)
                                .font(.headline)
                        } header: {
                            Text("タイトル")
                        }
                        
                        // Script Content Section
                        Section {
                            ZStack(alignment: .topLeading) {
                                if scriptText.isEmpty {
                                    Text("ここに台本を入力してください...")
                                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                                TextEditor(text: $scriptText)
                                    .frame(minHeight: 300)
                                    .font(.body)
                            }
                        } header: {
                            HStack {
                                Text("本文")
                                Spacer()
                                Text("\(scriptText.count)文字")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Settings Section
                        Section {
                            Toggle("時間制限モード", isOn: $useTimeLimit)
                                .onChange(of: useTimeLimit) { newValue in
                                    if !newValue { timeLimit = nil }
                                    else { updateTimeLimit() }
                                }
                            
                            if useTimeLimit {
                                HStack {
                                    Text("目標時間")
                                    Spacer()
                                    Picker("分", selection: $selectedMinutes) {
                                        ForEach(0..<11) { m in Text("\(m)分").tag(m) }
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: selectedMinutes) { _ in updateTimeLimit() }
                                    
                                    Picker("秒", selection: $selectedSeconds) {
                                        ForEach(0..<60, id: \.self) { s in Text("\(s)秒").tag(s) }
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: selectedSeconds) { _ in updateTimeLimit() }
                                }
                                
                                if let limit = timeLimit, limit > 0, !scriptText.isEmpty {
                                    HStack {
                                        Text("自動スクロール速度")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("約\(Int(calculatedScrollSpeed))px/秒")
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("スクロール速度")
                                        Spacer()
                                        Text("\(Int(scrollSpeed))")
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    Slider(value: $scrollSpeed, in: 10...100, step: 1)
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("スクロール設定")
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    // Save Button Area
                    VStack {
                        Button(action: saveScript) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("保存する")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!canSave)
                        .padding()
                    }
                    .background(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
                }
            }
            .navigationTitle("台本作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showScriptList = true }) {
                        Image(systemName: "list.bullet")
                        Text("一覧")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearScript) {
                        Text("クリア")
                    }
                    .disabled(scriptText.isEmpty && scriptTitle.isEmpty)
                }
            }
            .sheet(isPresented: $showScriptList) {
                ScriptListView(scriptManager: scriptManager, scriptText: $scriptText, scriptTitle: $scriptTitle, timeLimit: $timeLimit, useTimeLimit: $useTimeLimit)
            }
            .overlay(
                // Save Success Message
                Group {
                    if showSaveSuccess {
                        VStack {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Text("保存しました")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.black.opacity(0.8)))
                            .shadow(radius: 10)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(100)
                    }
                }
            )
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
        }
    }
    
    private var canSave: Bool {
        !scriptTitle.isEmpty && !scriptText.isEmpty
    }
    
    private func updateTimeLimit() {
        let totalSeconds = Double(selectedMinutes * 60 + selectedSeconds)
        timeLimit = totalSeconds > 0 ? totalSeconds : nil
    }
    
    private func clearScript() {
        scriptTitle = ""
        scriptText = ""
        useTimeLimit = false
        timeLimit = nil
        // Reset defaults if needed
        selectedMinutes = 1
        selectedSeconds = 0
    }
    
    private func saveScript() {
        guard canSave else { return }
        
        // Save logic...
        let totalSeconds = useTimeLimit ? Double(selectedMinutes * 60 + selectedSeconds) : nil
        let script = Script(title: scriptTitle, content: scriptText, timeLimit: totalSeconds)
        scriptManager.addScript(script)
        
        // Success feedback
        withAnimation { showSaveSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSaveSuccess = false }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
