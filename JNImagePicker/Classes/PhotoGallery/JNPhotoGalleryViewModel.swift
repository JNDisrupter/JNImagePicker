//
//  JNPhotoGalleryViewModel.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import Foundation
import Photos

/// JNPhoto Gallery View Model
class JNPhotoGalleryViewModel {
    
    /// Assets list
    private var assets: [PHAsset]
    
    /// Representables
    private var representables: [CollectionViewCellRepresentable]
    
    /// Selected assets
    private(set) var selectedAssets: Set<PHAsset>
    
    /// Max Selectable count
    private var maxSelectableCount: Int
    
    /// Single select
    private var singleSelect: Bool
    
    /// Sorce to use for media
    private var sourceType: JNImagePickerViewController.SourceType = .both
    
    /**
     Initilizer
     - Parameter singleSelect: Single select flag.
     - Parameter maxSelectableCount: Maximum Selectable Count
     - Parameter sourceType: Media source type
     */
    init(singleSelect: Bool, maxSelectableCount: Int, sourceType: JNImagePickerViewController.SourceType = .both) {
        self.singleSelect = singleSelect
        self.sourceType = sourceType
        self.assets = []
        self.representables = []
        self.selectedAssets = []
        self.maxSelectableCount = maxSelectableCount
    }
    
    /**
     Set selected assets
     - Parameter assets: Selected assets
     */
    func setSelectedAssets(_ selectedAssets: [JNAsset]) {
        self.selectedAssets = Set(selectedAssets.compactMap({ $0.originalAsset }))
        
        // Build representables
        self.buildRepresentables()
    }
    
    /**
     Set assets
     - Parameter assets: Assets Array
     */
    func setAssets(_ assets: [PHAsset]) {
        self.assets = assets.reversed()
        
        // Build representables
        self.buildRepresentables()
    }
    
    /**
     Build representables
     */
    private func buildRepresentables() {
        self.representables.removeAll()
        
        // Check if media source is both then show camera button
        if self.sourceType == JNImagePickerViewController.SourceType.both, AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            self.representables.append(JNCameraCollectionViewCellRepresentable())
        }
        
        for asset in self.assets {
            let isSelected = self.selectedAssets.contains(asset)
            let representable = JNImageCollectionViewCellRepresentable(asset: asset, isSelected: isSelected)
            self.representables.append(representable)
        }
    }
    
    /**
     Get number of rows in sections.
     - Parameter section: Section number as Int.
     - Returns: Number of rows in section as Int.
     */
    func numberOfItem(inSection section: Int) -> Int {
        return self.representables.count
    }
    
    /**
     Get cell representable at indexPath.
     - Parameter indexPath: Index path.
     - Returns: Cell representable as collection view cell representable.
     */
    func representableForItem(at indexPath: IndexPath) -> CollectionViewCellRepresentable? {
        if indexPath.row < self.representables.count {
            return self.representables[indexPath.row]
        }
        
        return nil
    }
    
    /**
     Select item at index path
     - Parameter indexPath: Index path for the item to select.
     */
    func selectItem(at indexPath: IndexPath) {
        if let representable = self.representableForItem(at: indexPath) as? JNImageCollectionViewCellRepresentable, let asset = representable.asset {
            if self.singleSelect {
                if let selectedItemIndexPath = self.selectedItemsIndexPaths().first {
                    if let representable = self.representableForItem(at: selectedItemIndexPath) as? JNImageCollectionViewCellRepresentable {
                        representable.isSelected = false
                    }
                }
                self.selectedAssets = [asset]
            } else {
                self.selectedAssets.insert(asset)
            }
            
            representable.isSelected = true
        }
    }
    
    /**
     Return if item is selected
     - Parameter indexPath: Index path.
     - Returns: Bool to indicate if selected.
     */
    func isItemSelected(at indexPath: IndexPath) -> Bool {
        if let representable = self.representableForItem(at: indexPath) as? JNImageCollectionViewCellRepresentable, let asset = representable.asset {
            return self.selectedAssets.contains(asset)
        }
        
        return false
    }
    
    /**
     Deselect item at index path
     - Parameter indexPath: Index path for the item to deselect.
     */
    func deselectItem(at indexPath: IndexPath) {
        if let representable = self.representableForItem(at: indexPath) as? JNImageCollectionViewCellRepresentable, let asset = representable.asset {
            self.selectedAssets.remove(asset)
            representable.isSelected = false
        }
    }
    
    /**
     Get index paths for selected items
     - Returns: Selected itme index paths
     */
    func selectedItemsIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath]  = []
        var representables = self.representables
        
        // Is first representable camera
        let isFirstRepresentableCamera: Bool = self.representables.first is JNCameraCollectionViewCellRepresentable
        
        // Remove camera option
        if isFirstRepresentableCamera {
            representables.remove(at: 0)
        }
        
        // Type cast representables
        if let imageReprsentables = representables as? [JNImageCollectionViewCellRepresentable] {
            
            // Filter selected items
            for (index, item) in imageReprsentables.enumerated() where item.isSelected {
                let row = index + (isFirstRepresentableCamera ? 1 : 0)
                indexPaths.append(IndexPath(row: row, section: 0))
            }
        }
        
        return indexPaths
    }
}
