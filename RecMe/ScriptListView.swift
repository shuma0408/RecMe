//
//  ScriptListView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct ScriptListView: View {
    @ObservedObject var scriptManager: ScriptManager
    @Binding var scriptText: String
    @Binding var scriptTitle: String
    @Binding var timeLimit: TimeInterval?
    @Binding var useTimeLimit: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(scriptManager.scripts) { script in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(script.title)
                            .font(.headline)
                        Text(script.content.prefix(50) + (script.content.count > 50 ? "..." : ""))
                            .font(.caption)
                            .foregroundColor(.gray)
                        if let limit = script.timeLimit {
                            Text("時間制限: \(Int(limit / 60))分\(Int(limit.truncatingRemainder(dividingBy: 60)))秒")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        scriptManager.selectScript(script)
                        scriptText = script.content
                        scriptTitle = script.title
                        timeLimit = script.timeLimit
                        useTimeLimit = script.timeLimit != nil
                        dismiss()
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        scriptManager.deleteScript(scriptManager.scripts[index])
                    }
                }
            }
            .navigationTitle("スクリプト一覧")
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
