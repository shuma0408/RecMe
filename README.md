# RecMe - スクリプトカメラアプリ

就活生向けの動画選考用テレプロンプターアプリです。

## 機能

- 📹 **動画録画**: カメラを見ながらスクリプトを読んで録画
- 📜 **スクリプト管理**: 複数のスクリプトを保存・管理
- ⏱️ **時間制限モード**: 指定時間内に完璧に読み終わる自動スクロール
- 🤖 **AI生成**: バックエンドAPI経由でスクリプトを自動生成
- 📤 **エクスポート**: 企業別の最適化プリセットで動画をエクスポート
- 📱 **動画一覧**: 録画した動画を一覧表示・再生・削除

## 技術スタック

- **言語**: Swift 5.0
- **フレームワーク**: SwiftUI
- **最小iOSバージョン**: iOS 16.0
- **カメラ**: AVFoundation
- **広告**: Google Mobile Ads SDK

## セットアップ

### 必要な環境

- Xcode 15.0以上
- iOS 16.0以上
- Swift 5.0以上

### インストール

1. リポジトリをクローン
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

2. Xcodeでプロジェクトを開く
```bash
open RecMe.xcodeproj
```

3. 依存関係を解決
- Xcodeが自動的にSwift Package Managerの依存関係を解決します

4. ビルド
- ⌘+B でビルド

## 設定

### 広告設定

`RecMe/RewardAdManager.swift`で広告ユニットIDを設定:

```swift
// テストモード
self.adUnitID = testAdUnitID

// 本番モード
self.adUnitID = productionAdUnitID
```

### バックエンドAPI設定

`RecMe/AIAssistantView.swift`でバックエンドAPIのURLを設定:

```swift
private let backendURL = "https://your-backend-api.com/api/generate-script"
```

詳細は `APP_SETTINGS_GUIDE.md` を参照してください。

## プロジェクト構造

```
RecMe/
├── scriptCamApp.swift          # アプリエントリーポイント
├── ContentView.swift            # メインビュー
├── RecordingView.swift          # 録画画面
├── ScriptEditView.swift         # スクリプト編集画面
├── CameraManager.swift          # カメラ管理
├── TeleprompterView.swift       # スクリプトスクロール表示
├── VideoListView.swift          # 動画一覧
├── RewardAdManager.swift        # リワード広告管理
├── AIService.swift              # AI API呼び出し
├── AppTheme.swift               # アプリテーマ
└── Assets.xcassets/             # アセット
```

## ライセンス

このプロジェクトのライセンス情報は LICENSE ファイルを参照してください。

## お問い合わせ

ご質問やご不明な点がございましたら、以下までお問い合わせください。

- Email: support@your-domain.com
- GitHub Issues: https://github.com/your-username/your-repo/issues

## 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずIssueを開いて変更内容を議論してください。

## 更新履歴

### 1.0.0 (2026-01-24)
- 初回リリース
- 基本的な録画機能
- スクリプト管理機能
- AI生成機能（バックエンドAPI経由）
- リワード広告統合
