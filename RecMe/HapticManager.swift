//
//  HapticManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// 軽いバイブレーション（録画開始など）
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 中程度のバイブレーション（録画停止など）
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 強いバイブレーション（重要なアクション）
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 成功のバイブレーション（動画保存完了など）
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// エラーのバイブレーション
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// 警告のバイブレーション
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
