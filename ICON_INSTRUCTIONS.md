# アプリアイコン作成手順

## 方法1: Pythonスクリプトを使用（推奨）

### 必要なもの
- Python 3
- Pillow ライブラリ: `pip install Pillow`

### 手順

1. 画像ファイルを準備（PNG形式推奨）

2. スクリプトを実行:
```bash
cd /Users/apple/Desktop/スクリプトカメラ/scriptCam
python3 create_app_icon.py <画像ファイルのパス>
```

3. 生成された `AppIcon-1024.png` を以下の場所に配置:
```
scriptCam/scriptCam/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
```

4. Xcodeでプロジェクトを開き、Assets.xcassetsのAppIconに画像をドラッグ&ドロップ

## 方法2: 手動で画像を処理

### 必要なサイズ
- **1024x1024ピクセル** (iOSアプリアイコンの標準サイズ)

### 処理手順

1. **画像編集ソフトで開く**（Photoshop、GIMP、Preview等）

2. **外側の水色のグローを除去**
   - 画像の端の部分を選択
   - 水色っぽい部分を削除または透明にする
   - または、中央のアイコン部分のみを選択して切り抜く

3. **角丸を適用**
   - iOSアプリアイコンは自動的に角丸が適用されますが、事前に角丸を適用することも可能
   - 角の半径: 約180ピクセル（1024x1024の場合）

4. **1024x1024にリサイズ**
   - 正方形にトリミング
   - 1024x1024ピクセルにリサイズ

5. **PNG形式で保存**
   - 透明度を保持するためPNG形式で保存

6. **Xcodeに配置**
   - `scriptCam/scriptCam/Assets.xcassets/AppIcon.appiconset/` に配置
   - XcodeでAssets.xcassetsを開き、AppIconに画像をドラッグ&ドロップ

## 画像の要件

- **形式**: PNG（透明度対応）
- **サイズ**: 1024x1024ピクセル
- **色空間**: sRGB
- **背景**: 透明または単色

## 注意事項

- アイコンの重要な要素（「Me」の文字、赤い円、矢印など）が中央に配置されていることを確認
- 外側の水色のグロー効果は完全に除去してください
- 画像の端は透明にするか、単色の背景にしてください
