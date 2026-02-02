//
//  FAQView.swift
//  scriptCam
//
//  Created by Apple on 2026/02/02.
//

import SwiftUI

struct FAQView: View {
    let faqs: [(question: String, answer: String)] = [
        ("録画時間はどのくらいですか？", "端末の空き容量に依存しますが、長時間の録画も可能です。スクリプトの設定で時間制限を設けることもできます。"),
        ("スクリプトはどこに保存されますか？", "アプリ内のデータベースに保存されます。アプリを削除するとスクリプトも削除されるのでご注意ください。"),
        ("録画した動画はどこにありますか？", "「録画一覧」タブから確認できます。写真アプリに保存したり、共有機能を使って外部に出力することも可能です。"),
        ("スクロール速度は調整できますか？", "はい、台本作成画面でスクロール速度を細かく調整できます。時間制限モードを使うと、指定した時間に合わせて自動で速度が計算されます。"),
        ("オフラインでも使えますか？", "はい、すべての機能をオフラインで利用いただけます。")
    ]
    
    var body: some View {
        List {
            ForEach(0..<faqs.count, id: \.self) { index in
                Section(header: Text(faqs[index].question).font(.headline)) {
                    Text(faqs[index].answer)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("よくある質問")
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FAQView()
        }
    }
}
