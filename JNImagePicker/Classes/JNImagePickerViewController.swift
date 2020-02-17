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
        .albumRegular,
        .albumCloudShared
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
    
    /// Image Deleviry mode
    public var imageDeliveryMode: PHImageRequestOptionsDeliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
    
    /// Video Deleviry mode
    public var videoDeliveryMode: PHVideoRequestOptionsDeliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
    
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
            self.setNavigationBarHidden(true, animated: false)
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
            
            // First, add the view of the child to the view of the parent
            self.view.addSubview(imagePickerViewController.view)
            imagePickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            imagePickerViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            imagePickerViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            imagePickerViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            imagePickerViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            
            // Then, add the child to the parent
            self.addChild(imagePickerViewController)
            
            // Finally, notify the child that it was moved to a parent
            imagePickerViewController.didMove(toParent: self)
        }
        
        func openGallery() {
            self.setNavigationBarHidden(false, animated: false)
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
            rootViewController.videoDeliveryMode = self.videoDeliveryMode
            rootViewController.imageDeliveryMode = self.imageDeliveryMode
            rootViewController.delegate = self
            
            self.setViewControllers([rootViewController], animated: false)
        }
        
        // Set default view controller
        self.setViewControllers([DefaultViewController()], animated: false)
        
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
                if granted {
                    if self.sourceType == SourceType.both {
                        JNAssetsManager.checkCameraPermission { (granted) in
                            if granted {
                                DispatchQueue.main.async {
                                    openGallery()
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            openGallery()
                        }
                    }
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
        
        // Get media type
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            
            // Image
            if mediaType == kUTTypeImage as String {
                var image: UIImage?
                
                // Set edited image
                if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    image = editedImage
                    
                    // Set original image
                } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    image = originalImage
                }
                
                // Get asset extension
                var assetExtension = "jpg"
                
                if #available(iOS 11.0, *) {
                    if let mediaExtension = (info[UIImagePickerController.InfoKey.imageURL] as? URL)?.pathExtension {
                        assetExtension = mediaExtension
                    }
                } else {
                    if let mediaExtension = (info[UIImagePickerController.InfoKey.referenceURL] as? URL)?.pathExtension {
                        assetExtension = mediaExtension
                    }
                }
                
                // Add image to assets
                if let image = image {
                    let jnAsset = JNAsset(image: image, assetExtension: assetExtension)
                    self.pickerDelegate?.imagePickerViewController(pickerController: self, didSelectAssets: [jnAsset])
                } else {
                    
                    // Failed to selecte asset
                    self.pickerDelegate?.imagePickerViewController(pickerController: self, failedToSelectAsset: nil)
                }
                
                // Vide type
            } else {
                
                // Video url
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    
                    // New video identifier
                    var newVideoIdentifier: String!
                    
                    // Perform changes
                    PHPhotoLibrary.shared().performChanges({
                        
                        // Create asset from video url
                        let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                        newVideoIdentifier = assetRequest?.placeholderForCreatedAsset?.localIdentifier
                    }) { (success, error) in
                        
                        DispatchQueue.main.async() {
                            
                            if success {
                                
                                // Fetch asset
                                if let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newVideoIdentifier], options: nil).firstObject {
                                    
                                    // Get video extension
                                    let assetExtension = videoURL.pathExtension.lowercased()
                                    
                                    // Create JNAsset
                                    var jnAsset = JNAsset(originalAsset: newAsset, assetExtension: assetExtension)
                                    do { jnAsset.assetData = try Data(contentsOf: videoURL) } catch { }
                                    
                                    // Did select asset
                                    self.pickerDelegate?.imagePickerViewController(pickerController: self, didSelectAssets: [jnAsset])
                                }
                            } else {
                                
                                // Failed to selecte asset
                                self.pickerDelegate?.imagePickerViewController(pickerController: self, failedToSelectAsset: error!)
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
        self.pickerDelegate?.imagePickerViewControllerDidCancelPicker()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - JNPhotoGalleryViewControllerDelegate
extension JNImagePickerViewController: JNPhotoGalleryViewControllerDelegate {
    
    /**
     Did select assets\
     - Parameter assets: Selected assets array
     */
    public func galleryViewController(didSelectAssets assets: [JNAsset]) {
        self.pickerDelegate?.imagePickerViewController(pickerController: self, didSelectAssets: assets)
    }
    
    /**
     Did Exceed Maximum image size.
     */
    public func galleryViewControllerDidExceedMaximumImageSize() {
        self.pickerDelegate?.imagePickerViewController(didExceedMaximumImageSize: self)
    }
}

/// JNImage Picker View Controller Delegate
public protocol JNImagePickerViewControllerDelegate: NSObjectProtocol {
 
    /**
     Did select assets
     - Parameter pickerController: The picker controller object.
     - Parameter assets: Array of selected assets.
     */
    func imagePickerViewController(pickerController: JNImagePickerViewController, didSelectAssets assets: [JNAsset])
    
    /**
     Failed to select assets.
     - Parameter pickerController: The picker controller object.
     - Parameter error: The error for failed to select.
     */
    func imagePickerViewController(pickerController: JNImagePickerViewController, failedToSelectAsset error: Error?)
    
    /**
     Did Exceed Maximum image size.
     - Parameter pickerController: The picker controller object.
     */
    func imagePickerViewController(didExceedMaximumImageSize pickerController: JNImagePickerViewController)
    
    /**
     Did cancel picker.
     */
    func imagePickerViewControllerDidCancelPicker()
}

/// Default view controller
class DefaultViewController: UIViewController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Init navigation ietm
        self.initNavigationItem()
    }
    
    // MARK: - Navigation item
    
    /**
     Init navigation item
     */
    private func initNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.didClickCancelButton))
    }
    
    /**
     Did click cancel button
     */
    @objc private func didClickCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
