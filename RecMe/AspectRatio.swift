//
//  AspectRatio.swift
//  scriptCam
//
//  Created by Apple on 2026/02/02.
//

import Foundation
import CoreGraphics

enum AspectRatio: String, CaseIterable {
    case original = "Original"
    case nineSixteen = "9:16"
    case fourFive = "4:5"
    case oneOne = "1:1"
    
    var ratio: CGFloat {
        switch self {
        case .original: return 0 // Special case for full screen
        case .nineSixteen: return 9.0 / 16.0
        case .fourFive: return 4.0 / 5.0
        case .oneOne: return 1.0
        }
    }
    
    var shortName: String {
        switch self {
        case .original: return "Full"
        case .nineSixteen: return "9:16"
        case .fourFive: return "4:5"
        case .oneOne: return "1:1"
        }
    }
}
