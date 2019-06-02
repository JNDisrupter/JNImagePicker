//
//  JNPhotoGalleryCollectionViewLayout.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import UIKit

/// JNPhoto Gallery Collection View Layout
class JNPhotoGalleryCollectionViewLayout: UICollectionViewFlowLayout {
    
    open override func prepare() {
        super.prepare()
        
        var minItemWidth: CGFloat = 80
        if UI_USER_INTERFACE_IDIOM() == .pad {
            minItemWidth = 100
        }
        
        let interval: CGFloat = 1
        self.minimumInteritemSpacing = interval
        self.minimumLineSpacing = interval
        
        let contentWidth = self.collectionView!.bounds.width
        
        let itemCount = Int(floor(contentWidth / minItemWidth))
        var itemWidth = (contentWidth - interval * (CGFloat(itemCount) - 1)) / CGFloat(itemCount)
        let actualInterval = (contentWidth - CGFloat(itemCount) * itemWidth) / (CGFloat(itemCount) - 1)
        itemWidth += actualInterval - interval
        
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        self.itemSize = itemSize
    }
    
}
