//
//  JNImageCollectionViewCellRepresentable.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import Foundation
import Photos

/// JNImage Collection View Cell Representable
class JNImageCollectionViewCellRepresentable: CollectionViewCellRepresentable {
    
    /// Reuse identifier
    var reuseIdentifier: String
    
    /// Asset object
    var asset: PHAsset?
    
    /// Cell size
    var cellSize: CGSize
    
    /// Is selected flag
    var isSelected: Bool
    
    /**
     Initilizer
     - Parameter asset: PHAsset Object.
     - Parameter isSelected: Is selected flag
     */
    init(asset: PHAsset, isSelected: Bool) {
        self.isSelected = isSelected
        self.reuseIdentifier = JNImageCollectionViewCell.getReuseIdentifier()
        self.asset = asset
        self.cellSize = CGSize.zero
    }
}
