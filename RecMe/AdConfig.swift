//
//  AdConfig.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import Foundation

/// 広告設定を管理するクラス
/// セキュリティのため、広告ユニットIDは環境変数や設定ファイルから読み込むことを推奨
class AdConfig {
    // AdMobアプリID（Info.plistに設定済み）
    // これは公開されても問題ありません
    static let appID = "ca-app-pub-2289723020512274~7514864529"
    
    // 広告ユニットID
    // セキュリティのため、環境変数やUserDefaultsから読み込むことを推奨
    static var rewardAdUnitID: String {
        // 1. 環境変数から読み込み（Xcodeのスキーム設定で設定可能）
        if let envID = ProcessInfo.processInfo.environment["REWARD_AD_UNIT_ID"], !envID.isEmpty {
            return envID
        }
        
        // 2. UserDefaultsから読み込み（アプリ内設定で変更可能）
        if let savedID = UserDefaults.standard.string(forKey: "reward_ad_unit_id"), !savedID.isEmpty {
            return savedID
        }
        
        // 3. デフォルト値（開発中はテストID、本番環境では本番ID）
        #if DEBUG
        // デバッグビルド: テスト広告ID
        return "ca-app-pub-3940256099942544/1712485313"
        #else
        // リリースビルド: 本番広告ID
        return "ca-app-pub-2289723020512274/7766145964"
        #endif
    }
    
    // テスト用の広告ユニットID（開発時のみ）
    static let testAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    // 本番環境の広告ユニットID
    static let productionAdUnitID = "ca-app-pub-2289723020512274/7766145964"
}
