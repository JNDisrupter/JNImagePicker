//
//  JNImagePickerViewController.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

/// JNImage Picker View Controller
open class JNImagePickerViewController: UINavigationController {
    
    /// Source Type
    public enum SourceType {
        case camera
        case gallery
        case both
    }
    
    /// Media Type
    public enum MediaType {
        case video
        case image
        case all
    }
    
    /// Forces deselect of previous selected image
    public var singleSelect = false
    
    /// The maximum count of assets which the user will be able to select.
    public var maxSelectableCount = 999
    
    /// The types of PHAssetCollection to display in the picker.
    public var assetGroupTypes: [PHAssetCollectionSubtype] = [
        .smartAlbumUserLibrary,
        .smartAlbumFavorites,
        .albumRegular
    ]
    
    /// The type of picker interface to be displayed by the controller.
    public var mediaType: MediaType = .all
    
    /// Sorce to use for media
    public var sourceType: SourceType = .both
    
    /// It will have selected the specific assets.
    public var defaultSelectedAssets: [JNAsset]?
    
    /// Maximum Image Size in MB default is -1 if -1 then there is no limit
    public var maximumImageSize: Double = -1
    
    /// Maximum Total Images Sizes in MB default is -1 if -1 then there is no limit
    public var maximumTotalImagesSizes: Double = -1
    
    /// Allow editing media after capturing, this value will be used when open camera
    public var allowEditing: Bool = false
    
    /// Picker delegate
    public weak var pickerDelegate: JNImagePickerViewControllerDelegate?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup root view controller
        self.setupRootViewController()
    }
    
    /**
     Setup root view controller
     */
    private func setupRootViewController() {
        func openCamera() {
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = .camera
            if self.mediaType == JNImagePickerViewController.MediaType.all {
                imagePickerViewController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            } else if self.mediaType == JNImagePickerViewController.MediaType.image {
                imagePickerViewController.mediaTypes = [kUTTypeImage as String]
            } else {
                imagePickerViewController.mediaTypes = [kUTTypeMovie as String]
            }
            
            imagePickerViewController.allowsEditing = self.allowEditing
            self.present(imagePickerViewController, animated: false, completion: nil)
        }
        
        // Check if camera then open camera
        if self.sourceType == .camera {
            self.setNavigationBarHidden(true, animated: false)
            
            // Check permission
            JNAssetsManager.checkCameraPermission { (granted) in
                if granted {
                    if self.mediaType == JNImagePickerViewController.MediaType.video {
                        JNAssetsManager.checkGalleryPermission { (granted) in
                            if granted {
                                DispatchQueue.main.async {
                                    openCamera()
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            openCamera()
                        }
                    }
                }
            }
        } else {
            
            // Check permission
            JNAssetsManager.checkGalleryPermission { (granted) in
                DispatchQueue.main.async {
                    let rootViewController = JNPhotoGalleryViewController()
                    rootViewController.maximumImageSize = self.maximumImageSize
                    rootViewController.maximumTotalImagesSizes = self.maximumTotalImagesSizes
                    rootViewController.assetGroupTypes = self.assetGroupTypes
                    rootViewController.mediaType = self.mediaType
                    rootViewController.sourceType = self.sourceType
                    rootViewController.singleSelect = self.singleSelect
                    rootViewController.maxSelectableCount = self.maxSelectableCount
                    rootViewController.defaultSelectedAssets = self.defaultSelectedAssets
                    rootViewController.allowEditing = self.allowEditing
                    
                    self.setViewControllers([rootViewController], animated: false)
                }
            }
        }
    }
}

// MARK: - UIImagePickerController, UINavigationControllerDelegate
extension JNImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     Did finish picking media with info
     */
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == kUTTypeImage as String {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    let jnAsset = JNAsset(image: image)
                    self.pickerDelegate?.imagePickerViewController(didSelectAssets: [jnAsset])
                    self.imagePickerControllerDidCancel(picker)
                }
            } else {
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    var newVideoIdentifier: String!
                    PHPhotoLibrary.shared().performChanges({
                        let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                        newVideoIdentifier = assetRequest?.placeholderForCreatedAsset?.localIdentifier
                    }) { (success, error) in
                        DispatchQueue.main.async() {
                            if success {
                                if let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newVideoIdentifier], options: nil).firstObject {
                                    var jnAsset = JNAsset(originalAsset: newAsset)
                                    do { jnAsset.assetData = try Data(contentsOf: videoURL) } catch { }
                                    
                                    self.pickerDelegate?.imagePickerViewController(didSelectAssets: [jnAsset])
                                    self.imagePickerControllerDidCancel(picker)
                                }
                            } else {
                                self.pickerDelegate?.imagePickerViewController(failedToSelectAsset: error!)
                                self.imagePickerControllerDidCancel(picker)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Image Picker Controller Did Cancel
     */
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

/// JNImage Picker View Controller Delegate
public protocol JNImagePickerViewControllerDelegate: NSObjectProtocol {
 
    /**
     Did select assets
     - Parameter assets: Array of selected assets.
     */
    func imagePickerViewController(didSelectAssets assets: [JNAsset])
    
    /**
     Failed to select assets.
     - Parameter error: The error for failed to select.
     */
    func imagePickerViewController(failedToSelectAsset error: Error)
}
