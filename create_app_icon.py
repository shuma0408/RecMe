#!/usr/bin/env python3
"""
アプリアイコン生成スクリプト
画像から外側の水色のグローを除去し、アイコン形状のみを切り取ります。
"""

from PIL import Image, ImageDraw, ImageFilter
import sys
import os

def create_app_icon(input_image_path, output_dir):
    """
    入力画像からアプリアイコンを生成
    
    Args:
        input_image_path: 入力画像のパス
        output_dir: 出力ディレクトリ
    """
    try:
        # 画像を読み込む
        img = Image.open(input_image_path).convert("RGBA")
        
        # 1024x1024にリサイズ（iOSアプリアイコンの標準サイズ）
        img = img.resize((1024, 1024), Image.Resampling.LANCZOS)
        
        # 角丸のマスクを作成（iOSアプリアイコンの角丸）
        mask = Image.new("L", (1024, 1024), 0)
        draw = ImageDraw.Draw(mask)
        
        # 角丸矩形を描画（角の半径は約180ピクセル、iOS標準）
        corner_radius = 180
        draw.rounded_rectangle(
            [(0, 0), (1024, 1024)],
            radius=corner_radius,
            fill=255
        )
        
        # マスクを適用して角丸にする
        output = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask)
        
        # 外側の水色のグローを除去（背景を透明にする）
        # 画像の端の部分を透明にする処理
        pixels = output.load()
        width, height = output.size
        
        # 画像の端から内側に向かって、水色っぽい部分を透明にする
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                
                # 水色っぽい色（青とシアンの組み合わせ）を検出
                # 外側の部分で、青みが強い部分を透明にする
                if (b > r + 50 and b > g + 30) or (g > 200 and b > 200 and r < 150):
                    # 外側の20%の領域のみ処理
                    edge_threshold = 0.2
                    if (x < width * edge_threshold or x > width * (1 - edge_threshold) or
                        y < height * edge_threshold or y > height * (1 - edge_threshold)):
                        pixels[x, y] = (r, g, b, 0)  # 透明にする
        
        # 出力ディレクトリを作成
        os.makedirs(output_dir, exist_ok=True)
        
        # 1024x1024のアイコンを保存
        output_path = os.path.join(output_dir, "AppIcon-1024.png")
        output.save(output_path, "PNG")
        
        print(f"✅ アプリアイコンを作成しました: {output_path}")
        print(f"📱 このファイルを Assets.xcassets/AppIcon.appiconset/ に配置してください")
        
        return output_path
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("使用方法: python3 create_app_icon.py <入力画像パス> [出力ディレクトリ]")
        print("例: python3 create_app_icon.py icon.png ./output")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "./app_icon_output"
    
    if not os.path.exists(input_path):
        print(f"❌ ファイルが見つかりません: {input_path}")
        sys.exit(1)
    
    create_app_icon(input_path, output_dir)
