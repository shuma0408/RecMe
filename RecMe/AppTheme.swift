//
//  AppTheme.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

/// アプリのテーマカラーとスタイルを定義
struct AppTheme {
    // プライマリカラー（録画ボタンなど）
    static let primaryColor = Color(red: 0.9, green: 0.4, blue: 0.2) // オレンジ/赤系
    static let primaryColorDark = Color(red: 1.0, green: 0.5, blue: 0.3) // ダークモード用
    
    // セカンダリカラー（補助的な要素）
    static let secondaryColor = Color(red: 0.2, green: 0.4, blue: 0.9) // 青系
    static let secondaryColorDark = Color(red: 0.3, green: 0.5, blue: 1.0) // ダークモード用
    
    // 成功カラー（保存完了など）
    static let successColor = Color.green
    
    // エラーカラー
    static let errorColor = Color.red
    
    // 警告カラー
    static let warningColor = Color.orange
    
    // 背景カラー
    static let backgroundColor = Color(.systemBackground)
    static let secondaryBackgroundColor = Color(.secondarySystemBackground)
    
    // テキストカラー
    static let primaryTextColor = Color(.label)
    static let secondaryTextColor = Color(.secondaryLabel)
    
    // カスタムカラー（アプリ固有）
    static let recordingColor = Color.red
    static let scriptTextColor = Color.white
    static let cameraIndicatorColor = Color.white
    
    // 角丸の半径
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 20
    
    // シャドウ
    static let shadowRadius: CGFloat = 10
    static let shadowColor = Color.black.opacity(0.2)
    
    // パディング
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
}

/// カスタムビューモディファイア
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppTheme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppTheme.secondaryColor)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppTheme.successColor)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

/// カスタムカードスタイル
struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.padding)
            .background(AppTheme.secondaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius)
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardStyle())
    }
}
