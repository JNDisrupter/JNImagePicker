//
//  CollectionViewCellRepresentable.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import Foundation

/// Collection View Cell Representable
protocol CollectionViewCellRepresentable {
 
    /// Reuse identifier
    var reuseIdentifier: String { set get }
    
    /// Cell size
    var cellSize: CGSize { set get }
}
