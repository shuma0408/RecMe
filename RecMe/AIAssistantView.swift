//
//  AIAssistantView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct AIAssistantView: View {
    @Binding var scriptText: String
    @Environment(\.dismiss) var dismiss
    
    @State private var keywords: String = ""
    @State private var selectedCategory: String = "ガクチカ"
    @State private var isGenerating: Bool = false
    @State private var generatedScript: String = ""
    @State private var errorMessage: String = ""
    @State private var showBackendSettings: Bool = false
    
    let categories = ["ガクチカ", "自己PR", "志望動機", "長所・短所", "挫折経験", "その他"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("AIスクリプト生成アシスタント")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("カテゴリ")
                        .font(.subheadline)
                    
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("キーワード（例: カフェバイト、売上向上、リーダー経験）")
                        .font(.subheadline)
                    
                    TextField("キーワードを入力", text: $keywords)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // バックエンド設定ボタン
                Button(action: {
                    showBackendSettings = true
                }) {
                    HStack {
                        Image(systemName: "server.rack")
                        Text("バックエンド設定")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    generateScript()
                }) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isGenerating ? "生成中..." : "スクリプトを生成")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGenerating ? Color.gray : Color.purple)
                    .cornerRadius(10)
                }
                .disabled(isGenerating || keywords.isEmpty)
                .padding(.horizontal)
                
                // エラーメッセージ
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if !generatedScript.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("生成されたスクリプト")
                            .font(.headline)
                        
                        ScrollView {
                            Text(generatedScript)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: 300)
                        
                        Button(action: {
                            scriptText = generatedScript
                            dismiss()
                        }) {
                            Text("このスクリプトを使用")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("AI生成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showBackendSettings) {
                BackendSettingsView()
            }
        }
    }
    
    private func generateScript() {
        isGenerating = true
        errorMessage = ""
        generatedScript = ""
        
        AIService.shared.generateScript(category: selectedCategory, keywords: keywords) { [self] result in
            isGenerating = false
            
            switch result {
            case .success(let script):
                generatedScript = script
            case .failure(let error):
                errorMessage = "エラー: \(error.localizedDescription)"
                // フォールバック: テンプレート生成
                generatedScript = generateTemplateScript(category: selectedCategory, keywords: keywords)
            }
        }
    }
    
    private func generateTemplateScript(category: String, keywords: String) -> String {
        // フォールバック用のテンプレート
        let template = """
        こんにちは。\(category)についてお話しさせていただきます。
        
        \(keywords)を通じて、私は以下のような経験を積むことができました。
        
        まず、\(keywords)において、具体的な成果として...
        
        この経験から学んだことは、\(keywords)の重要性です。
        
        今後は、この経験を活かして...
        
        以上が私の\(category)です。ご清聴ありがとうございました。
        """
        return template
    }
}

struct BackendSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var backendURL: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("バックエンドAPI設定")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("APIエンドポイントURL")
                        .font(.subheadline)
                    
                    TextField("https://your-backend-api.com/api/generate-script", text: $backendURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    Text("バックエンドAPIのエンドポイントURLを入力してください。\n\n【API仕様】\nリクエスト:\nPOST /api/generate-script\nContent-Type: application/json\n{\n  \"category\": \"ガクチカ\",\n  \"keywords\": \"カフェバイト、売上向上\"\n}\n\nレスポンス:\n{\n  \"script\": \"生成されたスクリプト...\"\n}\nまたは直接文字列でも可\n\n【バックエンド実装例（Gemini API）】\nGoogle Gemini APIを使用してスクリプトを生成してください。\nプロンプト例はAIService.swiftのcreatePromptForBackend()を参照。")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                Button(action: {
                    if !backendURL.isEmpty {
                        AIService.shared.setBackendURL(backendURL)
                        dismiss()
                    }
                }) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backendURL.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(backendURL.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("バックエンド設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                backendURL = AIService.shared.getBackendURL()
            }
        }
    }
}
