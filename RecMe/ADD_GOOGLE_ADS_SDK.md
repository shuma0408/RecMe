# Google Mobile Ads SDKの追加手順

## エラー解決方法

`No such module 'GoogleMobileAds'` エラーが発生している場合、以下の手順でGoogle Mobile Ads SDKを追加してください。

## 方法1: Xcodeで手動追加（推奨）

1. Xcodeでプロジェクトを開く
2. プロジェクトナビゲーターでプロジェクト名（RecMe）を選択
3. プロジェクト設定で「Package Dependencies」タブを選択
4. 「+」ボタンをクリック
5. 以下のURLを入力:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
6. バージョンを選択（最新版を推奨、例: 11.0.0以上）
7. 「Add Package」をクリック
8. パッケージが追加されたら、「Add to Target」で「RecMe」を選択
9. 「Add Package」をクリック
10. プロジェクトを再ビルド（⌘+B）

## 方法2: 一時的に広告機能を無効化

広告機能を後で追加する場合、以下のように一時的に無効化できます:

### RewardAdManager.swift
```swift
// import GoogleMobileAds をコメントアウト
// import GoogleMobileAds

class RewardAdManager: NSObject, ObservableObject {
    // GoogleMobileAds関連のコードを一時的にコメントアウト
    // または、モック実装に置き換え
}
```

### scriptCamApp.swift
```swift
// import GoogleMobileAds をコメントアウト
// import GoogleMobileAds

@main
struct scriptCamApp: App {
    init() {
        // GADMobileAds.sharedInstance().start(completionHandler: nil) をコメントアウト
    }
}
```

## 確認方法

SDKが正しく追加されたら、以下を確認:
- プロジェクトナビゲーターに「Package Dependencies」が表示される
- `import GoogleMobileAds` でエラーが消える
- ビルドが成功する

## トラブルシューティング

### パッケージがダウンロードされない場合
- インターネット接続を確認
- Xcodeを再起動
- Derived Dataをクリア: Product > Clean Build Folder (⇧⌘K)

### ビルドエラーが続く場合
- プロジェクトを閉じて再度開く
- Xcodeを再起動
- パッケージを削除して再度追加
