//
//  ScriptModel.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import Foundation

struct Script: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var timeLimit: TimeInterval? // 秒単位（nilの場合は手動速度）
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, content: String, timeLimit: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.timeLimit = timeLimit
        self.createdAt = Date()
    }
    
    // Equatable準拠のための実装（idで比較）
    static func == (lhs: Script, rhs: Script) -> Bool {
        return lhs.id == rhs.id
    }
}

// 企業別エクスポートプリセット
enum ExportPreset: String, CaseIterable, Identifiable {
    case mynavi = "マイナビ"
    case openES = "OpenES"
    case line = "LINE送信"
    case custom = "カスタム"
    
    var id: String { rawValue }
    
    var maxFileSizeMB: Int {
        switch self {
        case .mynavi: return 20
        case .openES: return 30
        case .line: return 10
        case .custom: return 50
        }
    }
    
    var videoQuality: String {
        switch self {
        case .mynavi: return "中"
        case .openES: return "高"
        case .line: return "低"
        case .custom: return "高"
        }
    }
}
