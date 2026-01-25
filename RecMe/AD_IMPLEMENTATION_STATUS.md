# 広告実装ステータス

## ✅ 完了している実装（自動で実装済み）

### 1. コード実装
- ✅ `RewardAdManager.swift` - リワード広告管理クラス
- ✅ `scriptCamApp.swift` - AdMob SDKの初期化
- ✅ `CameraManager.swift` - 動画保存時に広告表示
- ✅ `HapticManager.swift` - バイブレーション機能
- ✅ Google Mobile Ads SDKのパッケージ依存関係追加

### 2. 設定ファイル
- ✅ `project.pbxproj` - AdMobアプリID設定
  - `GADApplicationIdentifier = "ca-app-pub-2289723020512274~7514864529"`
- ✅ 広告ユニットIDの設定
  - テストID: `ca-app-pub-3940256099942544/1712485313`
  - 本番ID: `ca-app-pub-2289723020512274/7766145964`

### 3. 機能統合
- ✅ 動画保存時に自動的にリワード広告を表示
- ✅ 広告視聴完了後に次の広告を自動読み込み
- ✅ エラーハンドリング（広告が読み込めない場合のフォールバック）

## 📋 あなたが行う必要がある手順

### ステップ1: AdMobアカウントの確認

1. [Google AdMob](https://admob.google.com/) にログイン
2. アプリが正しく登録されているか確認
   - アプリID: `ca-app-pub-2289723020512274~7514864529`
   - 広告ユニットID: `ca-app-pub-2289723020512274/7766145964`

### ステップ2: 広告ユニットの確認

1. AdMobダッシュボードで「広告ユニット」を確認
2. リワード広告ユニットが作成されているか確認
3. 広告ユニットIDが正しいか確認: `ca-app-pub-2289723020512274/7766145964`

### ステップ3: テスト広告の確認（開発中）

現在、アプリはテストモードに設定されています。

**確認方法:**
1. アプリをビルドして実行
2. 動画を録画して保存
3. リワード広告が表示されることを確認
4. 広告を視聴して報酬を獲得
5. 動画が正常に保存されることを確認

**テスト広告ID**: `ca-app-pub-3940256099942544/1712485964`

### ステップ4: 本番環境への切り替え（リリース前）

**重要**: アプリをリリースする前に、本番環境の広告に切り替える必要があります。

1. `RecMe/RewardAdManager.swift` を開く
2. 以下の行を変更:

```swift
// 変更前（テストモード）
self.adUnitID = testAdUnitID

// 変更後（本番モード）
self.adUnitID = productionAdUnitID
```

または、`init()`メソッド内で:

```swift
override init() {
    if let savedAdUnitID = UserDefaults.standard.string(forKey: "reward_ad_unit_id"), !savedAdUnitID.isEmpty {
        self.adUnitID = savedAdUnitID
    } else {
        // 本番環境に切り替え
        self.adUnitID = productionAdUnitID  // ← ここを変更
    }
    
    super.init()
    loadRewardedAd()
}
```

### ステップ5: App Store Connectでの設定

1. [App Store Connect](https://appstoreconnect.apple.com/) にログイン
2. アプリを選択
3. 「App Privacy」セクションで以下を設定:
   - データ収集の種類を選択
   - 広告表示のためのデータ収集を有効化
   - プライバシーポリシーURLを設定

### ステップ6: テストフライトでの確認

1. TestFlightでアプリを配布
2. テストユーザーに広告が正しく表示されるか確認
3. 広告の視聴が正常に動作するか確認

### ステップ7: リリース前の最終確認

- [ ] 広告が本番環境のIDに切り替えられている
- [ ] AdMobでアプリと広告ユニットが正しく設定されている
- [ ] App Store Connectでプライバシー設定が完了している
- [ ] テストフライトで広告が正常に動作することを確認
- [ ] プライバシーポリシーにAdMobの情報が含まれている

## 🔍 トラブルシューティング

### 広告が表示されない場合

1. **ネットワーク接続を確認**
   - インターネット接続が必要です

2. **AdMobアカウントを確認**
   - アプリが正しく登録されているか
   - 広告ユニットが有効になっているか

3. **アプリIDを確認**
   - `Info.plist`の`GADApplicationIdentifier`が正しいか
   - Xcodeのコンソールでエラーメッセージを確認

4. **広告ユニットIDを確認**
   - `RewardAdManager.swift`の`adUnitID`が正しいか

5. **テストモードの確認**
   - 開発中はテスト広告IDを使用しているか確認

### エラーメッセージの確認方法

Xcodeのコンソールで以下のメッセージを確認:
- "リワード広告の読み込み完了" - 正常
- "リワード広告の読み込みエラー" - エラー内容を確認

## 📝 チェックリスト

### 開発中
- [x] Google Mobile Ads SDKが追加されている
- [x] AdMobアプリIDが設定されている
- [x] 広告ユニットIDが設定されている
- [x] コード実装が完了している
- [ ] テスト広告が正常に表示されることを確認

### リリース前
- [ ] 本番環境の広告IDに切り替え
- [ ] AdMobでアプリと広告ユニットを確認
- [ ] App Store Connectでプライバシー設定
- [ ] TestFlightで動作確認
- [ ] プライバシーポリシーにAdMob情報を追加

## 📚 参考リンク

- [AdMob公式ドキュメント](https://developers.google.com/admob/ios)
- [AdMobダッシュボード](https://admob.google.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
