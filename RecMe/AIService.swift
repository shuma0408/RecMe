//
//  AIService.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import Foundation

class AIService {
    static let shared = AIService()
    
    // バックエンドAPIのエンドポイント（環境変数や設定で変更可能）
    private var backendURL: String {
        get {
            UserDefaults.standard.string(forKey: "ai_backend_url") ?? "https://your-backend-api.com/api/generate-script"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ai_backend_url")
        }
    }
    
    // バックエンドに送信するプロンプト生成（参考用）
    func createPromptForBackend(category: String, keywords: String) -> String {
        return """
        就活の動画選考用のスクリプトを作成してください。
        
        カテゴリ: \(category)
        キーワード: \(keywords)
        
        以下の要件を満たすスクリプトを作成してください：
        1. 論理的で伝わりやすい構成
        2. 具体的なエピソードを含める
        3. 学びや成長を強調する
        4. 自然な話し言葉で書く
        5. 60秒程度で話せる長さ（200-300文字程度）
        
        スクリプトのみを返してください。説明やコメントは不要です。
        """
    }
    
    func generateScript(category: String, keywords: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: backendURL) else {
            // フォールバック: テンプレートベースの生成
            let template = generateTemplateScript(category: category, keywords: keywords)
            completion(.success(template))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let requestBody: [String: Any] = [
            "category": category,
            "keywords": keywords
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "リクエストボディの作成に失敗しました"])))
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    // ネットワークエラーの場合、フォールバック
                    let template = self.generateTemplateScript(category: category, keywords: keywords)
                    completion(.success(template))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    let template = self.generateTemplateScript(category: category, keywords: keywords)
                    completion(.success(template))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let template = self.generateTemplateScript(category: category, keywords: keywords)
                    completion(.success(template))
                }
                return
            }
            
            // 成功レスポンス（200-299）
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // バックエンドのレスポンス形式に応じて調整
                        // 例: {"script": "..."} または {"content": "..."} または直接文字列
                        if let script = json["script"] as? String {
                            DispatchQueue.main.async {
                                completion(.success(script.trimmingCharacters(in: .whitespacesAndNewlines)))
                            }
                        } else if let content = json["content"] as? String {
                            DispatchQueue.main.async {
                                completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                            }
                        } else if let message = json["message"] as? String {
                            DispatchQueue.main.async {
                                completion(.success(message.trimmingCharacters(in: .whitespacesAndNewlines)))
                            }
                        } else {
                            // JSONではなく直接文字列の場合
                            if let text = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
                                }
                            } else {
                                throw NSError(domain: "AIService", code: -6, userInfo: [NSLocalizedDescriptionKey: "レスポンスの解析に失敗しました"])
                            }
                        }
                    } else {
                        // JSONではなく直接文字列の場合
                        if let text = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
                            }
                        } else {
                            throw NSError(domain: "AIService", code: -6, userInfo: [NSLocalizedDescriptionKey: "レスポンスの解析に失敗しました"])
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        // パースエラーの場合、フォールバック
                        let template = self.generateTemplateScript(category: category, keywords: keywords)
                        completion(.success(template))
                    }
                }
            } else {
                // エラーレスポンスの場合
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = json["error"] as? String ?? json["message"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        }
                    } else {
                        throw NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "サーバーエラー: \(httpResponse.statusCode)"])
                    }
                } catch {
                    DispatchQueue.main.async {
                        // エラー解析失敗時、フォールバック
                        let template = self.generateTemplateScript(category: category, keywords: keywords)
                        completion(.success(template))
                    }
                }
            }
        }.resume()
    }
    
    private func generateTemplateScript(category: String, keywords: String) -> String {
        // フォールバック用のテンプレート（バックエンドが利用できない場合）
        let template = """
        こんにちは。\(category)についてお話しさせていただきます。
        
        \(keywords)を通じて、私は以下のような経験を積むことができました。
        
        まず、\(keywords)において、具体的な成果として...
        
        この経験から学んだことは、\(keywords)の重要性です。
        
        今後は、この経験を活かして...
        
        以上が私の\(category)です。ご清聴ありがとうございました。
        """
        return template
    }
    
    func setBackendURL(_ url: String) {
        backendURL = url
    }
    
    func getBackendURL() -> String {
        return backendURL
    }
}
