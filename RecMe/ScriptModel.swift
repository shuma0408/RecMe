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


