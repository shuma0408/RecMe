# リワード広告の設定手順

## 1. Google AdMobのセットアップ

### AdMobアカウントの作成
1. [Google AdMob](https://admob.google.com/) にアクセス
2. Googleアカウントでログイン
3. アプリを登録

### 広告ユニットIDの取得
1. AdMobダッシュボードで「広告ユニット」を選択
2. 「リワード広告」を選択して新しい広告ユニットを作成
3. 広告ユニットIDをコピー（例: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy`）

## 2. Xcodeプロジェクトの設定

### Google Mobile Ads SDKの追加

#### Swift Package Managerを使用する場合:
1. Xcodeでプロジェクトを開く
2. File > Add Packages...
3. 以下のURLを入力:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
4. バージョンを選択（最新版を推奨）
5. "Add to Target"でプロジェクトを選択

#### CocoaPodsを使用する場合:
1. `Podfile`に以下を追加:
   ```ruby
   pod 'Google-Mobile-Ads-SDK'
   ```
2. ターミナルで `pod install` を実行

### Info.plistの設定

`Info.plist`にAdMobアプリIDを追加:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

または、Xcodeのプロジェクト設定で:
- Target > Info > Custom iOS Target Properties
- `GADApplicationIdentifier` を追加
- 値にAdMobアプリIDを入力

## 3. コードの設定

### 広告ユニットIDの設定

`RewardAdManager.swift`の`adUnitID`を実際の広告ユニットIDに変更:

```swift
private let adUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy"
```

または、UserDefaultsから読み込むように設定:

```swift
UserDefaults.standard.set("ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy", forKey: "reward_ad_unit_id")
```

## 4. テスト広告

開発中はテスト広告ユニットIDを使用:
- テストID: `ca-app-pub-3940256099942544/1712485313`

本番環境では必ず実際の広告ユニットIDに変更してください。

## 5. 動作確認

1. アプリをビルドして実行
2. 動画を録画して保存
3. リワード広告が表示されることを確認
4. 広告を視聴して報酬を獲得
5. 動画が正常に保存されることを確認

## 注意事項

- テスト広告は本番環境では使用しないでください
- AdMobのポリシーに準拠してください
- 広告の読み込みには時間がかかる場合があります
- ネットワーク接続が必要です
