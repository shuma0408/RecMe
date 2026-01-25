//
//  RewardAdManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI
import GoogleMobileAds
import Combine

class RewardAdManager: NSObject, ObservableObject {
    static let shared = RewardAdManager()
    
    @Published var isAdReady: Bool = false
    @Published var isShowingAd: Bool = false
    
    private var rewardedAd: RewardedAd?
    private let adUnitID: String
    
    var onRewardEarned: (() -> Void)?
    
    override init() {
        // AdConfigから広告ユニットIDを取得
        // 環境変数 > UserDefaults > デフォルト値の順で読み込む
        self.adUnitID = AdConfig.rewardAdUnitID
        
        super.init()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("リワード広告の読み込みエラー: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isAdReady = false
                }
                return
            }
            
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            
            DispatchQueue.main.async {
                self.isAdReady = true
                print("リワード広告の読み込み完了")
            }
        }
    }
    
    func showRewardedAd(completion: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("リワード広告が読み込まれていません")
            // 広告が読み込まれていない場合でも、コールバックを実行（動画保存を許可）
            completion()
            // 次の広告を読み込む
            loadRewardedAd()
            return
        }
        
        // iOS 15以降の方法でルートビューコントローラーを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("ルートビューコントローラーが見つかりません")
            completion()
            loadRewardedAd()
            return
        }
        
        onRewardEarned = completion
        isShowingAd = true
        
        rewardedAd.present(from: rootViewController) { [weak self] in
            guard let self = self else { return }
            // リワードを獲得
            print("リワード広告の報酬を獲得しました")
            self.onRewardEarned?()
            self.onRewardEarned = nil
            self.isShowingAd = false
            // 次の広告を読み込む
            self.loadRewardedAd()
        }
    }
}

extension RewardAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("リワード広告が閉じられました")
        isShowingAd = false
        // 広告が閉じられた後、次の広告を読み込む
        loadRewardedAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("リワード広告の表示エラー: \(error.localizedDescription)")
        isShowingAd = false
        // エラーが発生した場合でも、コールバックを実行
        onRewardEarned?()
        onRewardEarned = nil
        // 次の広告を読み込む
        loadRewardedAd()
    }
}
