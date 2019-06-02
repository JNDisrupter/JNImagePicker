//
//  JNAsset.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/14/19.
//

import Foundation
import Photos

/// JN Asset
public struct JNAsset {
    
    public enum MediaType {
        case image
        case video
    }
    
    public var originalAsset: PHAsset?
    public var assetData: Data?
    public var assetInfo: [AnyHashable: Any]
    public var mediaType: MediaType
    
    init(image: UIImage) {
        self.originalAsset = nil
        self.assetData = image.jpegData(compressionQuality: 1)!
        self.assetInfo = [:]
        self.mediaType = MediaType.image
    }
    
    init(originalAsset: PHAsset?, assetData: Data, assetInfo: [AnyHashable: Any]) {
        self.originalAsset = originalAsset
        self.assetData = assetData
        self.assetInfo = assetInfo
        self.mediaType = originalAsset?.mediaType == PHAssetMediaType.video ? MediaType.video : MediaType.image
    }
    
    init(originalAsset: PHAsset?) {
        self.originalAsset = originalAsset
        self.assetData = nil
        self.assetInfo = [:]
        self.mediaType = originalAsset?.mediaType == PHAssetMediaType.video ? MediaType.video : MediaType.image
    }
}

// MARK: - Hashable
extension JNAsset: Hashable {
    
    // Synthesized by compiler
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.originalAsset)
        hasher.combine(self.assetData)
    }
    
    // Default implementation from protocol extension
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

// MARK: - Equatable
extension JNAsset: Equatable {
    public static func ==(lhs: JNAsset, rhs: JNAsset) -> Bool {
        return lhs.originalAsset == rhs.originalAsset
    }
}
