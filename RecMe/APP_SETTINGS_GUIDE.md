# アプリ設定ガイド

## 1. 広告設定

### テストモード / 本番モードの切り替え

`RewardAdManager.swift`で設定:

```swift
override init() {
    // テストモード（現在の設定）
    self.adUnitID = testAdUnitID  // テスト広告を表示
    
    // 本番モードに切り替える場合
    // self.adUnitID = productionAdUnitID  // 本番広告を表示
}
```

### 広告ユニットID

- **テストID**: `ca-app-pub-3940256099942544/1712485313`
- **本番ID**: `ca-app-pub-2289723020512274/7766145964`

## 2. プライバシーポリシーと利用規約

### 設定場所

`SettingsView.swift`でURLを設定:

```swift
private let privacyPolicyURL = "https://your-domain.com/privacy-policy"
private let termsOfServiceURL = "https://your-domain.com/terms-of-service"
```

### App Store Connectでの設定

1. App Store Connectにログイン
2. アプリを選択
3. 「App Privacy」セクションでプライバシーポリシーURLを設定
4. 「App Information」で利用規約URLを設定（オプション）

### Info.plistでの設定（オプション）

必要に応じて、`project.pbxproj`に以下を追加:

```swift
INFOPLIST_KEY_NSPrivacyPolicyURL = "https://your-domain.com/privacy-policy";
INFOPLIST_KEY_NSPrivacyPolicyURLUsageDescription = "プライバシーポリシーを表示します";
```

## 3. GitHub連携

### 設定場所

`SettingsView.swift`でGitHubリポジトリURLを設定:

```swift
private let githubURL = "https://github.com/your-username/your-repo"
```

### GitHubリポジトリの作成

1. GitHubで新しいリポジトリを作成
2. リポジトリURLを`SettingsView.swift`に設定
3. アプリからGitHubリポジトリにアクセス可能に

### ソースコード管理

#### Gitの初期化

```bash
cd /Users/apple/Desktop/スクリプトカメラ/scriptCam
git init
git add .
git commit -m "Initial commit"
```

#### GitHubにプッシュ

```bash
git remote add origin https://github.com/your-username/your-repo.git
git branch -M main
git push -u origin main
```

### .gitignoreの作成

プロジェクトルートに`.gitignore`を作成:

```
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
!*.xcworkspace/xcshareddata/

# User settings
xcuserdata/
*.xcuserstate
*.xcuserdatad

# Build
build/
DerivedData/

# Swift Package Manager
.swiftpm/
.build/

# CocoaPods
Pods/

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

# API Keys and Secrets
*.plist
!Info.plist
Secrets.swift
.env

# macOS
.DS_Store
.AppleDouble
.LSOverride
```

## 4. App Store Connectでの設定項目

### 必須項目

1. **アプリ情報**
   - アプリ名
   - サブタイトル
   - カテゴリー（Video）
   - 年齢制限

2. **プライバシー**
   - プライバシーポリシーURL（必須）
   - データ収集の種類と目的

3. **価格と配布**
   - 価格設定
   - 配布地域

4. **App Store情報**
   - 説明文
   - キーワード
   - スクリーンショット
   - アプリアイコン

### 推奨項目

1. **サポートURL**
   - お問い合わせ先
   - サポートページ

2. **マーケティングURL**
   - アプリの公式サイト（オプション）

3. **レビュー情報**
   - レビュー用のアカウント情報
   - レビュー用の説明

## 5. プライバシーポリシーのテンプレート

以下の内容を含める必要があります:

- 収集するデータの種類
- データの使用方法
- データの共有先
- ユーザーの権利
- 連絡先情報

### 例（日本語）

```
プライバシーポリシー

【個人情報の取り扱いについて】
本アプリは、以下の情報を収集・利用する場合があります：
- カメラ・マイクへのアクセス（動画録画のため）
- フォトライブラリへのアクセス（動画保存のため）

【広告について】
本アプリはGoogle AdMobを使用しており、広告表示のためにデバイス情報を収集する場合があります。
詳細はGoogle AdMobのプライバシーポリシーをご確認ください。

【お問い合わせ】
ご質問やご不明な点がございましたら、以下までお問い合わせください。
Email: support@your-domain.com
```

## 6. 利用規約のテンプレート

以下の内容を含める必要があります:

- サービスの利用条件
- 禁止事項
- 免責事項
- 知的財産権
- 利用規約の変更

## 7. チェックリスト

### リリース前の確認事項

- [ ] 広告を本番モードに切り替え
- [ ] プライバシーポリシーURLを設定
- [ ] 利用規約URLを設定（オプション）
- [ ] GitHubリポジトリURLを設定
- [ ] App Store Connectでアプリ情報を入力
- [ ] スクリーンショットを準備
- [ ] アプリアイコンを設定
- [ ] テストフライトでテスト
- [ ] プライバシー情報をApp Store Connectで設定

## 8. 参考リンク

- [App Store Connect](https://appstoreconnect.apple.com/)
- [AdMob](https://admob.google.com/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [GitHub](https://github.com/)
