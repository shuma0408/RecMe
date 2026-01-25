# アプリ設定まとめ

## iOS デプロイメントターゲット
- **最小バージョン**: iOS 16.0
- プロジェクト設定で `IPHONEOS_DEPLOYMENT_TARGET = 16.0` に設定済み

## アプリのテーマ設定

### プライマリカラー
- **ライトモード**: RGB(0.9, 0.4, 0.2) - オレンジ/赤系
- **ダークモード**: RGB(1.0, 0.5, 0.3) - より明るいオレンジ
- `Assets.xcassets/AccentColor.colorset` に設定済み

### カラーパレット（AppTheme.swift）
- **プライマリカラー**: 録画ボタンなど主要なアクション
- **セカンダリカラー**: 補助的な要素
- **成功カラー**: 保存完了など
- **エラーカラー**: エラー表示
- **警告カラー**: 警告表示

## アプリの向き設定
- **iPhone**: 縦向き・横向き対応（Portrait, LandscapeLeft, LandscapeRight）
- **iPad**: 全方向対応（Portrait, PortraitUpsideDown, LandscapeLeft, LandscapeRight）

## インターフェーススタイル
- **UIUserInterfaceStyle**: Automatic（ライト/ダークモード自動切り替え）

## ステータスバー
- **UIStatusBarStyle**: Default（システムデフォルト）

## App Category（App Storeカテゴリー）
- **カテゴリー**: Video（動画）
- `LSApplicationCategoryType = public.app-category.video`
- App Store Connectでアプリを提出する際の主要カテゴリー

## その他の設定

### 権限説明
- **カメラ**: "ビデオ撮影のためにカメラへのアクセスが必要です。"
- **マイク**: "ビデオ録画のためにマイクへのアクセスが必要です。"
- **フォトライブラリ**: "録画したビデオをフォトライブラリに保存するためにアクセスが必要です。"

### バンドルID
- `ss.app.dev0.RecMe`

### バージョン
- **マーケティングバージョン**: 1.0
- **ビルドバージョン**: 1

## カスタムスタイル

### ボタンスタイル
- `PrimaryButtonStyle`: プライマリアクション用
- `SecondaryButtonStyle`: セカンダリアクション用
- `SuccessButtonStyle`: 成功アクション用

### カードスタイル
- `appCardStyle()`: カード表示用のモディファイア

## 使用方法

### テーマカラーの使用例
```swift
// プライマリカラーを使用
Button("録画開始") {
    // アクション
}
.buttonStyle(PrimaryButtonStyle())

// カスタムカラーを使用
Text("テキスト")
    .foregroundColor(AppTheme.primaryColor)
```

### カードスタイルの使用例
```swift
VStack {
    Text("コンテンツ")
}
.appCardStyle()
```

## 注意事項

- iOS 16.0以上が必要です
- ダークモードとライトモードの両方に対応
- アクセントカラーはシステム全体で自動適用されます
