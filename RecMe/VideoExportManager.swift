//
//  VideoExportManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import AVFoundation
import UIKit
import Photos

class VideoExportManager {
    static let shared = VideoExportManager()
    
    func exportVideo(
        inputURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "VideoExport", code: -1, userInfo: [NSLocalizedDescriptionKey: "エクスポートセッションの作成に失敗しました"])))
            return
        }
        
        let outputURL = getOutputURL()
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(outputURL))
            case .failed:
                completion(.failure(exportSession.error ?? NSError(domain: "VideoExport", code: -1)))
            case .cancelled:
                completion(.failure(NSError(domain: "VideoExport", code: -2, userInfo: [NSLocalizedDescriptionKey: "エクスポートがキャンセルされました"])))
            default:
                completion(.failure(NSError(domain: "VideoExport", code: -3)))
            }
        }
    }
    
    func saveToPhotoLibrary(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                completion(.failure(NSError(domain: "VideoExport", code: -4, userInfo: [NSLocalizedDescriptionKey: "写真ライブラリへのアクセス権限がありません"])))
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "VideoExport", code: -5, userInfo: [NSLocalizedDescriptionKey: "保存に失敗しました"])))
                }
            }
        }
    }
    
    private func getOutputURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "exported_full_\(Date().timeIntervalSince1970).mp4"
        return documentsPath.appendingPathComponent(filename)
    }
}
