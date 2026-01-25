//
//  TeleprompterView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI

struct TeleprompterView: View {
    let text: String
    let scrollSpeed: Double
    let timeLimit: TimeInterval?
    let isActive: Bool
    
    var body: some View {
        TeleprompterScrollView(text: text, scrollSpeed: scrollSpeed, timeLimit: timeLimit, isActive: isActive)
    }
}

struct TeleprompterScrollView: UIViewRepresentable {
    let text: String
    let scrollSpeed: Double
    let timeLimit: TimeInterval?
    let isActive: Bool
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.layer.cornerRadius = 0
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        
        // 影を追加（読みやすくするため）
        textLabel.layer.shadowColor = UIColor.black.cgColor
        textLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        textLabel.layer.shadowRadius = 10
        textLabel.layer.shadowOpacity = 1.0
        
        scrollView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 200),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 40),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -40),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -200),
            textLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -80)
        ])
        
        context.coordinator.scrollView = scrollView
        context.coordinator.textLabel = textLabel
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // スクロール速度が変更された場合
        if context.coordinator.scrollSpeed != scrollSpeed {
            context.coordinator.scrollSpeed = scrollSpeed
            // 録画中の場合、新しい速度で再開
            if isActive && context.coordinator.isScrolling {
                context.coordinator.stopScrolling()
                context.coordinator.startScrolling(scrollView: uiView)
            }
        }
        
        // テキストが変更された場合
        if context.coordinator.textLabel?.text != text {
            context.coordinator.textLabel?.text = text
            DispatchQueue.main.async {
                uiView.layoutIfNeeded()
                context.coordinator.updateContentSize(uiView)
            }
        }
        
        // スクロール状態が変更された場合
        if isActive && !context.coordinator.isScrolling {
            context.coordinator.startScrolling(scrollView: uiView)
        } else if !isActive && context.coordinator.isScrolling {
            context.coordinator.stopScrolling()
            DispatchQueue.main.async {
                uiView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scrollSpeed: scrollSpeed, timeLimit: timeLimit)
    }
    
    class Coordinator: NSObject {
        var scrollView: UIScrollView?
        var textLabel: UILabel?
        var timer: Timer?
        var scrollSpeed: Double
        var timeLimit: TimeInterval?
        var isScrolling: Bool = false
        var currentOffset: CGFloat = 0
        var startTime: Date?
        
        init(scrollSpeed: Double, timeLimit: TimeInterval?) {
            self.scrollSpeed = scrollSpeed
            self.timeLimit = timeLimit
        }
        
        func startScrolling(scrollView: UIScrollView) {
            stopScrolling()
            isScrolling = true
            currentOffset = 0
            startTime = Date()
            
            // レイアウトを確定させる
            scrollView.layoutIfNeeded()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
                guard let self = self, let scrollView = self.scrollView, let textLabel = self.textLabel else { return }
                
                scrollView.layoutIfNeeded()
                textLabel.layoutIfNeeded()
                
                // テキストの実際の高さと位置を取得
                let textLabelFrame = textLabel.frame
                let textHeight = textLabelFrame.height
                let viewHeight = scrollView.bounds.height
                
                // 最後の文字が画面上部を通過するまでスクロール
                // textLabelのtopは200、bottomは-200の余白がある
                // 最後の文字が画面上部を通過 = textLabelのbottom位置が画面上部を通過
                // textLabelのbottom = textTopPadding + textHeight
                // スクロール位置が textTopPadding + textHeight に到達すれば、最後の文字が画面上部を通過
                let textTopPadding: CGFloat = 200
                let finalOffset = max(0, textTopPadding + textHeight)
                
                // 時間制限モードの場合、経過時間に基づいて位置を計算
                if let limit = self.timeLimit, let start = self.startTime, limit > 0 {
                    let elapsed = Date().timeIntervalSince(start)
                    let progress = min(elapsed / limit, 1.0)
                    // 最後まで流れ切るように、finalOffsetまで確実に到達
                    self.currentOffset = Double(finalOffset) * progress
                    
                    // 最後まで到達したら停止
                    if progress >= 1.0 {
                        scrollView.setContentOffset(
                            CGPoint(x: 0, y: finalOffset),
                            animated: false
                        )
                        self.stopScrolling()
                    } else {
                        scrollView.setContentOffset(
                            CGPoint(x: 0, y: self.currentOffset),
                            animated: false
                        )
                    }
                } else {
                    // 通常モード：速度ベース
                    let pixelsPerSecond = self.scrollSpeed
                    self.currentOffset += pixelsPerSecond * 0.016
                    
                    // 画面上に文字がなくなるまで流れ切る
                    if self.currentOffset >= finalOffset {
                        scrollView.setContentOffset(
                            CGPoint(x: 0, y: finalOffset),
                            animated: false
                        )
                        // 最後まで到達したら少し待ってから停止
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.stopScrolling()
                        }
                    } else {
                        scrollView.setContentOffset(
                            CGPoint(x: 0, y: self.currentOffset),
                            animated: false
                        )
                    }
                }
            }
        }
        
        func stopScrolling() {
            timer?.invalidate()
            timer = nil
            isScrolling = false
            currentOffset = 0
            startTime = nil
        }
        
        func updateContentSize(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                scrollView.layoutIfNeeded()
            }
        }
    }
}
