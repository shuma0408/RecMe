//
//  CameraPreviewView.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = cameraManager.getPreviewLayer()
        previewLayer.frame = view.bounds
        
        // デバイスの向きに応じてプレビューを回転
        updatePreviewLayerOrientation(previewLayer: previewLayer)
        
        view.layer.insertSublayer(previewLayer, at: 0)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            // プレビューレイヤーのフレームを更新
            for layer in uiView.layer.sublayers ?? [] {
                if let previewLayer = layer as? AVCaptureVideoPreviewLayer {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    previewLayer.frame = uiView.bounds
                    // 向きを更新
                    updatePreviewLayerOrientation(previewLayer: previewLayer)
                    CATransaction.commit()
                    return
                }
            }
            
            // プレビューレイヤーが見つからない場合は追加
            let previewLayer = cameraManager.getPreviewLayer()
            previewLayer.frame = uiView.bounds
            updatePreviewLayerOrientation(previewLayer: previewLayer)
            uiView.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    private func updatePreviewLayerOrientation(previewLayer: AVCaptureVideoPreviewLayer) {
        guard let connection = previewLayer.connection else { return }
        
        // デバイスの現在の向きを取得
        let orientation = UIDevice.current.orientation
        
        // 縦向き（ポートレート）に固定
        if connection.isVideoOrientationSupported {
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                // 横向きでも縦向きに表示
                connection.videoOrientation = .portrait
            case .landscapeRight:
                // 横向きでも縦向きに表示
                connection.videoOrientation = .portrait
            default:
                // デフォルトは縦向き
                connection.videoOrientation = .portrait
            }
        }
    }
}
