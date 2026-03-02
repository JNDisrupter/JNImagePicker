//
//  JNCameraCollectionViewCellRepresentable.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/19/19.
//

import Foundation
import Photos

/// JNCamera Collection View Cell Representable
class JNCameraCollectionViewCellRepresentable: CollectionViewCellRepresentable {
    
    /// Reuse identifier
    var reuseIdentifier: String
    
    /// Cell size
    var cellSize: CGSize
    
    /**
     Initilizer
     */
    init() {
        self.reuseIdentifier = JNCameraCollectionViewCell.getReuseIdentifier()
        self.cellSize = CGSize.zero
    }
}
