//
//  scriptCamApp.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI
import GoogleMobileAds

@main
struct scriptCamApp: App {
    init() {
        // Google Mobile Ads SDKの初期化
        // 新しいSDKでは、Info.plistのGADApplicationIdentifierが設定されていれば自動初期化されます
        // 明示的な初期化が必要な場合は、以下のように呼び出します
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(AppTheme.primaryColor) // アプリ全体のアクセントカラーを設定
        }
    }
}
