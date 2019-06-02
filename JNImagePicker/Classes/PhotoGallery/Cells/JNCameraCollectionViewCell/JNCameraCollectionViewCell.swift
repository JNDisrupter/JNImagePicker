//
//  JNCameraCollectionViewCell.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import UIKit
import Photos

/// JNCamera Collection View Cell
class JNCameraCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Class methods
    
    /**
     Get reuse identifier
     - Returns: Reuse identifier.
     */
    class func getReuseIdentifier() -> String {
        return "JNCameraCollectionViewCell"
    }
    
    /**
     Register cell
     - Parameter collectionView: The UICollectionView to register cells in it.
     */
    class func registerCell(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "JNCameraCollectionViewCell", bundle: Bundle.init(for: JNCameraCollectionViewCell.self)), forCellWithReuseIdentifier: self.getReuseIdentifier())
    }
}
