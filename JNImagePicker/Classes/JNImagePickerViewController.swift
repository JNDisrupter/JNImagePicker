//
//  JNImagePickerViewController.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//
import Foundation
import UIKit
import Photos
import PhotosUI
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
    
    /// Maximum Media Size in MB default is -1 if -1 then there is no limit
    public var maximumMediaSize: Double = -1
    
    /// Maximum Total Media Sizes in MB default is -1 if -1 then there is no limit
    public var maximumTotalMediaSizes: Double = -1
    
    /// Allow editing media after capturing, this value will be used when open camera
    public var allowEditing: Bool = false
    
    /// JN Image Picker Localization Configuration
    public var localizationConfiguration: JNImagePickerLocalizationConfiguration = JNImagePickerLocalizationConfiguration()
    
    /// Image Deleviry mode
    public var imageDeliveryMode: PHImageRequestOptionsDeliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
    
    /// Video Deleviry mode
    public var videoDeliveryMode: PHVideoRequestOptionsDeliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
    
    /// Picker delegate
    public weak var pickerDelegate: JNImagePickerViewControllerDelegate?
    
    /**
     Init with coder
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set hides bottom bar when pushed
        self.hidesBottomBarWhenPushed = true
        
        // Disable dismiss gesture for presented view controller in iOS 13
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        // This controls whether this view controller takes over control of the status bar's appearance when presented non-full screen on another view controller
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    /**
     Init with nib name and bundle
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Set hides bottom bar when pushed
        self.hidesBottomBarWhenPushed = true
        
        // Disable dismiss gesture for presented view controller in iOS 13
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        // This controls whether this view controller takes over control of the status bar's appearance when presented non-full screen on another view controller
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    /**
     Init
     */
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        // Set hides bottom bar when pushed
        self.hidesBottomBarWhenPushed = true
        
        // Disable dismiss gesture for presented view controller in iOS 13
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        // This controls whether this view controller takes over control of the status bar's appearance when presented non-full screen on another view controller
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Setup Background Color
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = true
        
        // Setup root view controller
        self.setupRootViewController()
    }
    
    /// Preferred Status Bar Style
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /// Prefers Status Bar Hidden
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: Navigation Bar
    /**
     Setup root view controller
     */
    private func setupRootViewController() {
        
        func openCamera() {
            self.setNavigationBarHidden(true, animated: false)
            
            // Set default view controller as the root view controller
            let defaultViewController = DefaultViewController()
            defaultViewController.viewType = .camera(mediaType: self.mediaType, allowEditing: self.allowEditing)
            self.setViewControllers([defaultViewController], animated: false)
        }
        
        func openGallery() {
            self.setNavigationBarHidden(false, animated: false)
            let rootViewController = JNPhotoGalleryViewController()
            rootViewController.maximumMediaSize = self.maximumMediaSize
            rootViewController.maximumTotalMediaSizes = self.maximumTotalMediaSizes
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
        
        /**
         Show photo settings alert
         */
        func showPhotoSettingsAlertViewController() {
            
            // Show error message
            let alertController = UIAlertController(title: self.localizationConfiguration.photoPermissionDeniedView.title, message: self.localizationConfiguration.photoPermissionDeniedView.message, preferredStyle: .alert)
            
            // Add cancel action
            alertController.addAction(UIAlertAction(title: self.localizationConfiguration.photoPermissionDeniedView.cancelAction, style: .cancel, handler: { [weak self] (_) in
                
                guard let self = self else {return}
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            // Add settings action
            alertController.addAction(UIAlertAction(title: self.localizationConfiguration.photoPermissionDeniedView.openSettingsAction, style: .default, handler: { [weak self] (_) in
                
                guard let self = self else {return}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                
                // Dismiss View
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true)
        }
        
        /**
         Show camera settings alert
         */
        func showCameraSettingsAlertViewController() {
            
            // Show error message
            let alertController = UIAlertController(title: self.localizationConfiguration.cameraPermissionDeniedView.title, message: self.localizationConfiguration.cameraPermissionDeniedView.message, preferredStyle: .alert)
            
            // Add cancel action
            alertController.addAction(UIAlertAction(title: self.localizationConfiguration.cameraPermissionDeniedView.cancelAction, style: .cancel, handler: { [weak self] (_) in
                
                guard let self = self else {return}
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            // Add settings action
            alertController.addAction(UIAlertAction(title: self.localizationConfiguration.cameraPermissionDeniedView.openSettingsAction, style: .default, handler: { [weak self] (_) in
                
                guard let self = self else {return}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                
                // Dismiss View
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true)
        }
        
        // Set default view controller
        self.setViewControllers([DefaultViewController()], animated: false)
        
        // Check if camera then open camera
        if self.sourceType == .camera {
            
            // Check permission
            JNAssetsManager.checkCameraPermission { (granted) in
                if granted {
                    if self.mediaType != JNImagePickerViewController.MediaType.image {
                        JNAssetsManager.checkGalleryPermission { (granted) in
                            if granted {
                                DispatchQueue.main.async {
                                    openCamera()
                                }
                            }else {
                                DispatchQueue.main.async {
                                    showPhotoSettingsAlertViewController()
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            openCamera()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        showCameraSettingsAlertViewController()
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
                }else{
                    DispatchQueue.main.async {
                        showPhotoSettingsAlertViewController()
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerController, UINavigationControllerDelegate
extension JNImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     Is media size valid
     - Parameter data: Media data.
     - Returns: Boolean to indicate image data is with valid size
     */
    private func isMediaSizeValid(_ data: Data) -> Bool {
        
        // Get maximum media size
        let maximumMediaSize = self.maximumMediaSize > -1 ? self.maximumMediaSize : self.maximumTotalMediaSizes
        
        // Check if image size greater than maximum images sizes
        if maximumMediaSize > -1 && Double(data.count) >= (maximumMediaSize * 1024 * 1024) {
            return false
        }
        
        return true
    }
    
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
                    
                    // Get asset data
                    if let assetData = jnAsset.assetData {
                        
                        // Check if data has valid size
                        if self.isMediaSizeValid(assetData) {

                            self.pickerDelegate?.imagePickerViewController(pickerController: self, didSelectAssets: [jnAsset])
                            return
                            
                        } else {
                            
                            let actualMediaSize = Double(assetData.count / (1024*1024))
                            self.pickerDelegate?.imagePickerViewController(didExceedMaximumMediaSizeFor: JNImagePickerViewController.MediaType.image, with: self.maximumMediaSize, actualMediaSize: actualMediaSize)
                            return
                        }
                    }
                }
                
                // Failed to selecte asset
                self.pickerDelegate?.imagePickerViewController(pickerController: self, failedToSelectAsset: nil)
                
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
                                    do {
                                        jnAsset.assetData = try Data(contentsOf: videoURL)
                                    } catch {
                                        // Failed to selecte asset
                                        self.pickerDelegate?.imagePickerViewController(pickerController: self, failedToSelectAsset: error)
                                    }
                                    
                                    // Get asset data
                                    if let assetData = jnAsset.assetData {
                                        
                                        // Check if data has valid size
                                        if self.isMediaSizeValid(assetData) {
                                            
                                            self.pickerDelegate?.imagePickerViewController(pickerController: self, didSelectAssets: [jnAsset])
                                            return
                                            
                                        } else {
                                            
                                            let actualMediaSize = Double(assetData.count / (1024*1024))
                                            self.pickerDelegate?.imagePickerViewController(didExceedMaximumMediaSizeFor: JNImagePickerViewController.MediaType.video, with: self.maximumMediaSize, actualMediaSize: actualMediaSize)
                                            return
                                        }
                                    }
                                }
                            }
                            
                            // Failed to selecte asset
                            self.pickerDelegate?.imagePickerViewController(pickerController: self, failedToSelectAsset: error!)
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
     Did exceed maximum media size for
     - Parameter mediaType: Media Type.
     - Parameter maximumSize: Media MAximum size.
     - Parameter actualMediaSize: Selected media size
     */
    public func galleryViewController(didExceedMaximumMediaSizeFor mediaType: JNImagePickerViewController.MediaType, with maximumSize: Double, actualMediaSize: Double) {
        self.pickerDelegate?.imagePickerViewController(didExceedMaximumMediaSizeFor: mediaType, with: maximumSize, actualMediaSize: actualMediaSize)
    }
    
    /**
     Did exceed maximum total media sizes for
     - Parameter mediaType: Media Type.
     - Parameter maximumTotalSizes: Media Total Maximum size.
     - Parameter actualMediaSizes: Selected media Total size
     - Parameter selectedMediaCount: Selected media Count
     */
    public func galleryViewController(didExceedMaximumTotalMediaSizesFor mediaType: JNImagePickerViewController.MediaType, with maximumTotalSizes: Double, actualMediaSizes: Double, selectedMediaCount: Int) {
        self.pickerDelegate?.imagePickerViewController(didExceedMaximumTotalMediaSizesFor: mediaType, with: maximumTotalSizes, actualMediaSizes: actualMediaSizes, selectedMediaCount: selectedMediaCount)
    }
    
    /**
     Did cancel picker.
     */
    public func galleryViewControllerDidCancelPicker() {
        self.pickerDelegate?.imagePickerViewControllerDidCancelPicker()
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
     Did exceed maximum media size for
     - Parameter mediaType: Media Type.
     - Parameter maximumSize: Media MAximum size.
     - Parameter actualMediaSize: Selected media size
     */
    func imagePickerViewController(didExceedMaximumMediaSizeFor mediaType: JNImagePickerViewController.MediaType, with maximumSize: Double, actualMediaSize: Double)
    
    /**
     Did exceed maximum total media sizes for
     - Parameter mediaType: Media Type.
     - Parameter maximumTotalSizes: Media Total Maximum size.
     - Parameter actualMediaSizes: Selected media Total size
     - Parameter selectedMediaCount: Selected media Count
     */
    func imagePickerViewController(didExceedMaximumTotalMediaSizesFor mediaType: JNImagePickerViewController.MediaType, with maximumTotalSizes: Double, actualMediaSizes: Double, selectedMediaCount: Int)
    
    /**
     Did cancel picker.
     */
    func imagePickerViewControllerDidCancelPicker()
}

/// Default view controller
class DefaultViewController: UIViewController {
        
    /// View Type
    enum ViewType {
        case blank
        case camera(mediaType: JNImagePickerViewController.MediaType, allowEditing: Bool)
    }
    
    // View type
    var viewType: ViewType = .blank
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Init navigation ietm
        //self.initNavigationItem()
        
        if case ViewType.camera(let mediaType, let allowEditing) = self.viewType {
            
            // Show camera
            self.showCamera(mediaType: mediaType, allowEditing: allowEditing)
        }
    }
    
    // MARK: - Navigation item
    
    /**
     Init navigation item
     */
    private func initNavigationItem() {
        
        /// Cancel Bar ButtonItem Title
        var cancelBarButtonItemTitle = ""
        
        // Get Navigation Controller
        if let navigationController = self.navigationController as? JNImagePickerViewController {
            cancelBarButtonItemTitle = navigationController.localizationConfiguration.cancelString
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: cancelBarButtonItemTitle, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.didClickCancelButton))
    }
    
    /**
     Show Camera
     - Parameter mediaType: Media type
     - Parameter allowEditting: flag to indicate if editting is allowed
     */
    private func showCamera(mediaType: JNImagePickerViewController.MediaType, allowEditing: Bool) {

        let imagePickerViewController = UIImagePickerController()
        
        if let jnImagePickerViewController = self.navigationController as? JNImagePickerViewController {
            imagePickerViewController.delegate = jnImagePickerViewController
        }
        
        imagePickerViewController.sourceType = .camera
        if mediaType == JNImagePickerViewController.MediaType.all {
            imagePickerViewController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        } else if mediaType == JNImagePickerViewController.MediaType.image {
            imagePickerViewController.mediaTypes = [kUTTypeImage as String]
        } else {
            imagePickerViewController.mediaTypes = [kUTTypeMovie as String]
        }
        
        imagePickerViewController.allowsEditing = allowEditing
        
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
    
    /**
     Did click cancel button
     */
    @objc private func didClickCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
