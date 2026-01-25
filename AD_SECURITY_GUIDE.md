# 広告IDのセキュリティ管理ガイド

## ❌ GitHubに広告IDを公開する必要はありません

広告ユニットIDをGitHubに公開する必要は**ありません**。むしろ、セキュリティのため**公開しないことを推奨**します。

## 🔒 現在の実装状況

### 公開されても問題ないもの
- ✅ **AdMobアプリID** (`ca-app-pub-2289723020512274~7514864529`)
  - Info.plistに含まれるため、アプリをビルドすると含まれます
  - これは公開されても問題ありません

### 公開を避けるべきもの
- ⚠️ **広告ユニットID** (`ca-app-pub-2289723020512274/7766145964`)
  - 現在、コード内にハードコードされています
  - GitHubにプッシュすると公開されてしまいます

## ✅ 推奨される管理方法

### 方法1: ビルド設定で管理（推奨）

`AdConfig.swift`を使用して、デバッグ/リリースビルドで自動的に切り替え:

```swift
#if DEBUG
// デバッグ: テスト広告ID
return "ca-app-pub-3940256099942544/1712485313"
#else
// リリース: 本番広告ID
return "ca-app-pub-2289723020512274/7766145964"
#endif
```

**メリット:**
- コードに直接含まれるが、ビルド設定で自動切り替え
- シンプルで管理しやすい

### 方法2: 環境変数で管理（より安全）

Xcodeのスキーム設定で環境変数を設定:

1. Xcodeで Product > Scheme > Edit Scheme
2. Run > Arguments > Environment Variables
3. `REWARD_AD_UNIT_ID` を追加
4. 値に広告ユニットIDを設定

**メリット:**
- コードに含まれない
- 環境ごとに異なるIDを設定可能

### 方法3: ローカル設定ファイル（最も安全）

1. `AdConfig.local.swift.example` をコピー
2. `AdConfig.local.swift` を作成
3. 実際の広告ユニットIDを設定
4. `.gitignore` に含まれているため、GitHubに公開されない

**メリット:**
- GitHubに公開されない
- 開発者ごとに異なる設定が可能

## 📝 現在の実装

`AdConfig.swift`を追加しました。以下の順序で広告ユニットIDを読み込みます:

1. **環境変数** (`REWARD_AD_UNIT_ID`)
2. **UserDefaults** (`reward_ad_unit_id`)
3. **デフォルト値** (デバッグ/リリースで自動切り替え)

## 🔍 GitHubにプッシュする前に確認

### チェックリスト

- [ ] `.gitignore` に `AdConfig.local.swift` が含まれている
- [ ] 広告ユニットIDがハードコードされていない（`AdConfig.swift`を使用）
- [ ] 機密情報がコードに含まれていない

### 確認方法

```bash
# 広告ユニットIDがコードに含まれているか確認
grep -r "ca-app-pub-2289723020512274/7766145964" RecMe/
```

もし見つかった場合、`AdConfig.swift`を使用するように変更してください。

## 🚨 注意事項

### 広告ユニットIDが公開された場合

広告ユニットIDが公開されても、**即座に問題が発生するわけではありません**が、以下のリスクがあります:

- 他の開発者が同じIDを使用する可能性
- 広告の収益が正確に計測されない可能性
- セキュリティベストプラクティスに反する

### 推奨対応

1. 新しい広告ユニットIDを作成（オプション）
2. `AdConfig.swift`を使用してIDを管理
3. 今後は環境変数やローカル設定ファイルで管理

## 📚 参考

- [AdMob公式ドキュメント](https://developers.google.com/admob/ios)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
