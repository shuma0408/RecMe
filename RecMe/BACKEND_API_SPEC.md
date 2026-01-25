# バックエンドAPI仕様（Gemini API使用）

## エンドポイント

```
POST /api/generate-script
Content-Type: application/json
```

## リクエスト

```json
{
  "category": "ガクチカ",
  "keywords": "カフェバイト、売上向上、リーダー経験"
}
```

## レスポンス

### 成功時（200 OK）

```json
{
  "script": "こんにちは。ガクチカについてお話しさせていただきます。\n\nカフェバイトを通じて、私は売上向上に取り組みました..."
}
```

または直接文字列でも可：
```
"こんにちは。ガクチカについてお話しさせていただきます..."
```

### エラー時（400, 500など）

```json
{
  "error": "エラーメッセージ"
}
```

## バックエンド実装例（Gemini API）

### Node.js / Express の例

```javascript
const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

app.post('/api/generate-script', async (req, res) => {
  try {
    const { category, keywords } = req.body;
    
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    
    const prompt = `就活の動画選考用のスクリプトを作成してください。

カテゴリ: ${category}
キーワード: ${keywords}

以下の要件を満たすスクリプトを作成してください：
1. 論理的で伝わりやすい構成
2. 具体的なエピソードを含める
3. 学びや成長を強調する
4. 自然な話し言葉で書く
5. 60秒程度で話せる長さ（200-300文字程度）

スクリプトのみを返してください。説明やコメントは不要です。`;
    
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const script = response.text();
    
    res.json({ script: script.trim() });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Python / Flask の例

```python
from flask import Flask, request, jsonify
import google.generativeai as genai
import os

app = Flask(__name__)
genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))

@app.route('/api/generate-script', methods=['POST'])
def generate_script():
    try:
        data = request.json
        category = data.get('category')
        keywords = data.get('keywords')
        
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = f"""就活の動画選考用のスクリプトを作成してください。

カテゴリ: {category}
キーワード: {keywords}

以下の要件を満たすスクリプトを作成してください：
1. 論理的で伝わりやすい構成
2. 具体的なエピソードを含める
3. 学びや成長を強調する
4. 自然な話し言葉で書く
5. 60秒程度で話せる長さ（200-300文字程度）

スクリプトのみを返してください。説明やコメントは不要です。"""
        
        response = model.generate_content(prompt)
        script = response.text.strip()
        
        return jsonify({'script': script})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=3000)
```

## 環境変数

バックエンドサーバーで以下の環境変数を設定：

```
GEMINI_API_KEY=your-gemini-api-key-here
```

Gemini APIキーは以下で取得：
https://makersuite.google.com/app/apikey
