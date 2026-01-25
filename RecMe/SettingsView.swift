//
//  SettingsView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // プライバシーポリシーと利用規約のURL（Notionページ）
    private let privacyPolicyURL: String? = "https://www.notion.so/RecMe-2f2792f57df980d28d7de0fd9910855a"
    private let termsOfServiceURL: String? = "https://www.notion.so/RecMe-2f2792f57df980d28d7de0fd9910855a"
    private let githubURL: String? = nil // "https://github.com/your-username/your-repo"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("法的情報")) {
                    if let privacyURL = privacyPolicyURL, let url = URL(string: privacyURL) {
                        Link(destination: url) {
                            HStack {
                                Text("プライバシーポリシー")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Text("未設定")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    if let termsURL = termsOfServiceURL, let url = URL(string: termsURL) {
                        Link(destination: url) {
                            HStack {
                                Text("利用規約")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        HStack {
                            Text("利用規約")
                            Spacer()
                            Text("未設定")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("開発")) {
                    if let github = githubURL, let url = URL(string: github) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "link")
                                Text("GitHub")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "link")
                            Text("GitHub")
                            Spacer()
                            Text("未設定")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("サポート")) {
                    Button(action: {
                        if let url = URL(string: "mailto:support@your-domain.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("お問い合わせ")
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
}
