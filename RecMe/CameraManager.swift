//
//  CameraManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import AVFoundation
import UIKit
import Photos
import Combine

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    @Published var isRecording: Bool = false
    @Published var hasPermission: Bool = false
    @Published var lastRecordedVideoURL: URL?
    
    var onRecordingFinished: ((URL) -> Void)?
    
    func setupCamera() {
        // 権限チェック
        checkPermissions { [weak self] granted in
            guard let self = self, granted else {
                print("カメラまたはマイクの権限がありません")
                return
            }
            
            DispatchQueue.main.async {
                self.hasPermission = true
                self.configureSession()
            }
        }
    }
    
    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch cameraStatus {
        case .authorized:
            // カメラ権限あり、マイク権限をチェック
            switch microphoneStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    completion(granted)
                }
            default:
                completion(false)
            }
        case .notDetermined:
            // カメラ権限をリクエスト
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    // マイク権限をチェック
                    let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                    switch micStatus {
                    case .authorized:
                        completion(true)
                    case .notDetermined:
                        AVCaptureDevice.requestAccess(for: .audio) { micGranted in
                            completion(micGranted)
                        }
                    default:
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func configureSession() {
        // セッション設定を開始
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // セッション設定
        captureSession.sessionPreset = .high
        
        // 既存の入力を削除
        if let existingInput = videoDeviceInput {
            captureSession.removeInput(existingInput)
        }
        
        // ビデオデバイスの取得
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("カメラが見つかりません")
            return
        }
        
        do {
            // ビデオ入力の作成
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                videoDeviceInput = videoInput
            } else {
                print("ビデオ入力を追加できません")
                return
            }
            
            // オーディオ入力の追加
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            }
            
            // ムービーファイル出力の追加
            if captureSession.canAddOutput(movieFileOutput) {
                captureSession.addOutput(movieFileOutput)
            } else {
                print("ムービー出力を追加できません")
            }
            
        } catch {
            print("カメラの設定に失敗しました: \(error.localizedDescription)")
            return
        }
        
        // セッション開始（バックグラウンドスレッドで実行）
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func startRecording(scriptTitle: String? = nil) {
        guard !isRecording else { return }
        guard captureSession.isRunning else {
            print("カメラセッションが実行されていません")
            return
        }
        
        // 録画の向きを設定（現在のデバイスの向きに合わせる）
        if let connection = movieFileOutput.connection(with: .video),
           connection.isVideoOrientationSupported {
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            default:
                // 不明な場合は縦向きをデフォルト
                connection.videoOrientation = .portrait
            }
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Date().timeIntervalSince1970
        let filename: String
        if let title = scriptTitle, !title.isEmpty {
            let sanitizedTitle = title.components(separatedBy: .init(charactersIn: "/\\?%*|\"<>:")).joined(separator: "_")
            filename = "video_\(sanitizedTitle)_\(timestamp).mov"
        } else {
            filename = "video_\(timestamp).mov"
        }
        
        let videoPath = documentsPath.appendingPathComponent(filename)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.movieFileOutput.isRecording == false {
                self.movieFileOutput.startRecording(to: videoPath, recordingDelegate: self)
                self.isRecording = true
            }
        }
    }
    
    private var targetAspectRatio: AspectRatio = .original
    
    func stopRecording(aspectRatio: AspectRatio = .original) {
        guard isRecording else { return }
        self.targetAspectRatio = aspectRatio
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.movieFileOutput.isRecording {
                self.movieFileOutput.stopRecording()
            }
            self.isRecording = false
        }
    }
    
    private func cropVideo(sourceURL: URL, aspectRatio: AspectRatio, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: sourceURL)
        
        // 映像トラックを取得
        guard let track = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        let composition = AVMutableVideoComposition()
        // トラックの自然なサイズと変換を取得して、レンダリングサイズを決定
        let trackSize = track.naturalSize
        let transform = track.preferredTransform
        
        // 変換後のサイズを計算（回転を考慮）
        let videoSize: CGSize
        if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) || // Portrait
           (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) { // PortraitUpsideDown
            videoSize = CGSize(width: trackSize.height, height: trackSize.width)
        } else {
            videoSize = trackSize
        }
        
        let width = videoSize.width
        let height = videoSize.height
        let targetRatio = aspectRatio.ratio
        
        var newWidth = width
        var newHeight = height
        
        if width / height > targetRatio {
            newWidth = height * targetRatio
        } else {
            newHeight = width / targetRatio
        }
        
        composition.renderSize = CGSize(width: newWidth, height: newHeight)
        composition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        // センタークロップのためのオフセット計算
        let xOffset = (width - newWidth) / 2
        let yOffset = (height - newHeight) / 2
        
        // 変換行列の構築: 回転(preferredTransform) -> 移動(-xOffset, -yOffset)
        // 注意: 座標系の関係で、回転後の座標系で移動する必要がある
        let moveTransform = CGAffineTransform(translationX: -xOffset, y: -yOffset)
        let finalTransform = transform.concatenating(moveTransform)
        
        layerInstruction.setTransform(finalTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        composition.instructions = [instruction]
        
        // エクスポートセッション
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "cropped_\(Int(Date().timeIntervalSince1970)).mp4"
        let outputURL = documentsPath.appendingPathComponent(filename)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = composition
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(outputURL)
            } else {
                print("Crop export failed: \(String(describing: exportSession.error))")
                completion(nil)
            }
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            
            // 現在のデバイスの向きに設定
            if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
                let orientation = UIDevice.current.orientation
                switch orientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeRight:
                    connection.videoOrientation = .landscapeRight
                default:
                    // 不明な場合は縦向きをデフォルト
                    connection.videoOrientation = .portrait
                }
            }
        }
        return previewLayer!
    }
    
    func updateVideoOrientation() {
        guard let previewLayer = previewLayer,
              let connection = previewLayer.connection,
              connection.isVideoOrientationSupported else { return }
        
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        default:
            // 不明な向きの場合は現在の向きを維持
            break
        }
    }
    
    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("録画エラー: \(error)")
            HapticManager.shared.error()
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.targetAspectRatio == .original {
                self.lastRecordedVideoURL = outputFileURL
                self.onRecordingFinished?(outputFileURL)
                HapticManager.shared.success()
            } else {
                // Crop video
                self.cropVideo(sourceURL: outputFileURL, aspectRatio: self.targetAspectRatio) { croppedURL in
                    DispatchQueue.main.async {
                        if let url = croppedURL {
                            self.lastRecordedVideoURL = url
                            self.onRecordingFinished?(url)
                            HapticManager.shared.success()
                            // Delete original file
                            try? FileManager.default.removeItem(at: outputFileURL)
                        } else {
                            // Fallback to original
                            print("Cropping failed, saving original")
                            self.lastRecordedVideoURL = outputFileURL
                            self.onRecordingFinished?(outputFileURL)
                            HapticManager.shared.error()
                        }
                    }
                }
            }
        }
    }
}
