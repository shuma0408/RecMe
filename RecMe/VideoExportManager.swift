//
//  VideoExportManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import AVFoundation
import UIKit

class VideoExportManager {
    static let shared = VideoExportManager()
    
    func exportVideo(
        inputURL: URL,
        preset: ExportPreset,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: getPresetName(for: preset)) else {
            completion(.failure(NSError(domain: "VideoExport", code: -1, userInfo: [NSLocalizedDescriptionKey: "エクスポートセッションの作成に失敗しました"])))
            return
        }
        
        let outputURL = getOutputURL(for: preset)
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // ファイルサイズ制限に合わせて圧縮
        if let maxSize = getMaxFileSize(for: preset) {
            exportSession.fileLengthLimit = Int64(maxSize)
        }
        
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
    
    private func getPresetName(for preset: ExportPreset) -> String {
        switch preset {
        case .mynavi, .openES:
            return AVAssetExportPresetMediumQuality
        case .line:
            return AVAssetExportPresetLowQuality
        case .custom:
            return AVAssetExportPresetHighestQuality
        }
    }
    
    private func getMaxFileSize(for preset: ExportPreset) -> Int? {
        switch preset {
        case .mynavi:
            return 20 * 1024 * 1024 // 20MB
        case .openES:
            return 30 * 1024 * 1024 // 30MB
        case .line:
            return 10 * 1024 * 1024 // 10MB
        case .custom:
            return 50 * 1024 * 1024 // 50MB
        }
    }
    
    private func getOutputURL(for preset: ExportPreset) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "exported_\(preset.rawValue)_\(Date().timeIntervalSince1970).mp4"
        return documentsPath.appendingPathComponent(filename)
    }
}
