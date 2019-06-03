//
//  JNAssetsManager.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import Foundation
import Photos

/// JNAssets Manager
class JNAssetsManager {
    
    /**
     Check permission to access assets
     - Parameter completion: Completion block.
     */
    class func checkGalleryPermission(_ completion: @escaping (_ granted: Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            completion(true)
        } else {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    completion(status == PHAuthorizationStatus.authorized)
                }
            } else {
                completion(false)
            }
        }
    }
    
    /**
     Check permission to access camera
     - Parameter completion: Completion block.
     */
    class func checkCameraPermission(_ completion: @escaping (_ granted: Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    /**
     Get asset collections
     - Parameter type: The type for asset collection
     - Parameter subType: Subtype for collection
     - Returns: Result contains all collections
     */
    func getAssetCollections(type: PHAssetCollectionType, subType: PHAssetCollectionSubtype, options: PHFetchOptions?) -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: type, subtype: subType, options: options)
    }
    
    /**
     Get asset collections for subtypes
     - Parameter subTypes: Array of Subtype for collection
     - Returns: Result contains all collections
     */
    func getAssetCollections(subTypes: [PHAssetCollectionSubtype], options: PHFetchOptions?) -> [PHAssetCollection] {
        var result = [PHAssetCollection]()
        
        for subtype in subTypes {
            let type = subtype.rawValue < PHAssetCollectionSubtype.smartAlbumGeneric.rawValue ? PHAssetCollectionType.album : PHAssetCollectionType.smartAlbum
            let fetchresult = self.getAssetCollections(type: type, subType: subtype, options: options)
            fetchresult.enumerateObjects { (collection, index, poiner) in
                result.append(collection)
            }
        }
        
        return result
    }
    
    /**
     Get assets in collection
     - Parameter collection: PHAsset collection to assets for
     - Parameter options: Options to fetch assets for.
     - Returns: Result of all assets
     */
    func getAssets(in collection: PHAssetCollection, options: PHFetchOptions?) -> [PHAsset] {
        var assets = [PHAsset]()
        
        PHAsset.fetchAssets(in: collection, options: options).enumerateObjects { (asset, count, pointer) in
            assets.append(asset)
        }
        
        return assets
    }
    
    /**
     Get assets in collection for specific media type
     - Parameter collection: PHAsset collection to assets for
     - Parameter type: Media type to fetch for.
     - Returns: Result of all assets
     */
    func getAssets(in collection: PHAssetCollection, type: PHAssetMediaType) -> [PHAsset] {
        let optionsToFilterImage = PHFetchOptions()
        optionsToFilterImage.predicate = NSPredicate(format: "mediaType = %d", type.rawValue)
        
        return self.getAssets(in: collection, options: optionsToFilterImage)
    }
    
    /**
     Get asset collection thumbnail
     - Parameter collection: The collection to get thumbnail for.
     - Parameter size: Size for the thumbnail.
     - Parameter completion: Completion block.
     */
    func getAssetCollectionThumbnail(collection: PHAssetCollection, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        if let firstAsset = self.getAssets(in: collection, options: nil).first {
            PHImageManager.default().requestImage(for: firstAsset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, options) in
                completion(image)
            }
        }
        
        completion(nil)
    }
}
