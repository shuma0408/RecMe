//
//  SettingsView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // プライバシーポリシーと利用規約のURL（GitHub Pages）
    private let privacyPolicyURL: String? = "https://shuma0408.github.io/RecMe/privacy.html"
    private let termsOfServiceURL: String? = "https://shuma0408.github.io/RecMe/terms.html"
    
    // サポートメールアドレス
    private let supportEmail = "ss.app.dev0@gmail.com"
    
    var body: some View {
        NavigationView {
            List {
                // サポートセクション
                Section(header: Text("サポート")) {
                    Button(action: {
                        if let url = URL(string: "mailto:\(supportEmail)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("サポートに問い合わせる")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                         requestReview()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("アプリを評価する")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.green)
                            Text("よくある質問")
                        }
                    }
                }
                
                // 法的情報セクション
                Section(header: Text("法的情報")) {
                    if let privacyURL = privacyPolicyURL, let url = URL(string: privacyURL) {
                        Link(destination: url) {
                            HStack {
                                Text("プライバシーポリシー")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if let termsURL = termsOfServiceURL, let url = URL(string: termsURL) {
                        Link(destination: url) {
                            HStack {
                                Text("利用規約")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func requestReview() {
        // App Storeのレビューページを開く、またはアプリ内レビューをリクエスト
        // ここでは簡易的にアプリ内レビューをリクエスト
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
