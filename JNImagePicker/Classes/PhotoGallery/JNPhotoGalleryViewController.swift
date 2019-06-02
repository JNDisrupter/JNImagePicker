//
//  JNPhotoGalleryViewController.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import UIKit
import Photos
import MobileCoreServices

/// JNPhoto Gallery View Controller
class JNPhotoGalleryViewController: UIViewController {

    /// Select Asset Collection Button
    public lazy var selectAssetCollectionButton: UIButton = {
        let button = UIButton()
        let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
        button.setTitleColor(globalTitleColor ?? UIColor.black, for: .normal)
        let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.font] as? UIFont
        button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(self, action: #selector(self.didClickSelectAssetCollectionButton), for: .touchUpInside)
        return button
    }()
    
    /// Collection view
    internal var collectionView: UICollectionView!
    
    /// Assets manager
    private var assetsManager: JNAssetsManager!
    
    /// Collections list
    private var collectionsList: [PHAssetCollection] = []
    
    /// Selected Asset collection
    private var selectedAssetCollection: PHAssetCollection?
    
    /// View model
    private var viewModel: JNPhotoGalleryViewModel!
    
    /// Maximum Image Size in MB default is -1 if -1 then there is no limit
    public var maximumImageSize: Double = -1
    
    /// Maximum Total Images Sizes in MB default is -1 if -1 then there is no limit
    public var maximumTotalImagesSizes: Double = -1
    
    /// The Types of PHAssetCollection to display in the picker.
    public var assetGroupTypes: [PHAssetCollectionSubtype]!
    
    /// Forces deselect of previous selected image
    public var singleSelect = false
    
    /// The maximum count of assets which the user will be able to select.
    public var maxSelectableCount = 999
    
    /// It will have selected the specific assets.
    public var defaultSelectedAssets: [JNAsset]?
    
    /// The type of picker interface to be displayed by the controller.
    public var mediaType: JNImagePickerViewController.MediaType = .all
    
    /// Sorce to use for media
    public var sourceType: JNImagePickerViewController.SourceType = .both
    
    /// Allow editing media after capturing, this value will be used when open camera
    public var allowEditing: Bool = false
    
    /// Delegate
    public weak var delegate: JNPhotoGalleryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init assets manager
        self.assetsManager = JNAssetsManager()
        
        // Get collections list
        self.collectionsList = self.assetsManager.getAssetCollections(subTypes: self.assetGroupTypes, options: nil)
        self.selectedAssetCollection = self.collectionsList.first
        
        // Init view model
        self.viewModel = JNPhotoGalleryViewModel(singleSelect: self.singleSelect, maxSelectableCount: self.maxSelectableCount, sourceType: sourceType)
        self.viewModel.setSelectedAssets(self.defaultSelectedAssets ?? [])
        
        // Load assets
        self.loadAssets()
        
        // Init collection view
        self.initCollectionView()
        
        // Update select asset collection button
        self.updateSelectAssetCollectionButton()
        
        // Init navigation item
        self.initNavigationItem()
    }
    
    /**
     Load assets
     */
    private func loadAssets() {
        
        var mediaType = PHAssetMediaType.image
        
        if self.mediaType == .all {
            let createImagePredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let createVideoPredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            let optionsToFilterImage = PHFetchOptions()
            optionsToFilterImage.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [createImagePredicate, createVideoPredicate])
            
            // Set asset list
            self.viewModel.setAssets(self.assetsManager.getAssets(in: self.selectedAssetCollection!, options: optionsToFilterImage))
            return
        } else if self.mediaType == .video {
            mediaType = .video
        }
        
        // Set asset list
        self.viewModel.setAssets(self.assetsManager.getAssets(in: self.selectedAssetCollection!, type: mediaType))
    }
    
    // MARK: - Collection view
    
    /**
     Init collection view
     */
    private func initCollectionView() {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: JNPhotoGalleryCollectionViewLayout())
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = !self.singleSelect
        self.view.addSubview(self.collectionView)
        
        // Add collection view constraints
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        // Register cell
        JNImageCollectionViewCell.registerCell(collectionView: self.collectionView)
        JNCameraCollectionViewCell.registerCell(collectionView: self.collectionView)
    }
    
    // MARK: - Navigation item
    
    /**
     Init navigation item
     */
    private func initNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.didClickCancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.didClickDoneButton))
    }
    
    /**
     Did click cancel button
     */
    @objc private func didClickCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Did click done button
     */
    @objc private func didClickDoneButton() {
        let loadingView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingView.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingView)
        
        var selectedAssets: [JNAsset] = []
        var imagesRequests: [PHImageRequestID] = []
        let assets = self.viewModel.selectedAssets
        var imageSizeExceedLimit = false
        
        func isImageSizeValid(_ imageData: Data?) -> Bool {
            guard let imageData = imageData else { return false }
            
            // Check if image size greater than maximum images sizes
            if self.maximumImageSize > -1 && Double(imageData.count) >= (self.maximumImageSize * 1024 * 1024) {
                return false
            }
            
            return true
        }
        
        func cancelImagesRequests() {
            for request in imagesRequests {
                PHImageManager.default().cancelImageRequest(request)
            }
        }
        
        for asset in assets {
           let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: nil) { [weak self] (data, string, imageOrientation, info) in
                
                guard let strongSelf = self, !imageSizeExceedLimit else { return }
                
                // Check if image size is valid
                if isImageSizeValid(data) {
                    selectedAssets.append(JNAsset(originalAsset: asset, assetData: data!, assetInfo: info ?? [:]))
                } else {
                    imageSizeExceedLimit = true
                    strongSelf.delegate?.JNPhotoGalleryViewControllerDidExceedMaximumImageSize()
                    strongSelf.initNavigationItem()
                    cancelImagesRequests()
                    return
                }
                
                if selectedAssets.count == assets.count {
                    let totalImagesSize = selectedAssets.reduce(0, { (result, asset) -> Int in
                        result + (asset.assetData?.count ?? 0)
                    })
                    
                    if strongSelf.maximumTotalImagesSizes > -1 && Double(totalImagesSize) >= (strongSelf.maximumTotalImagesSizes * 1024 * 1024) {
                        strongSelf.delegate?.JNPhotoGalleryViewControllerDidExceedMaximumImageSize()
                        strongSelf.initNavigationItem()
                    } else {
                        strongSelf.delegate?.JNPhotoGalleryViewController(didSelectAssets: selectedAssets)
                        strongSelf.didClickCancelButton()
                    }
                }
            }
            
            imagesRequests.append(imageRequestID)
        }
    }
    
    /**
     Update select asset collection button
     */
    private func updateSelectAssetCollectionButton() {
        let collectionName = self.selectedAssetCollection?.localizedTitle ?? ""
        self.selectAssetCollectionButton.isEnabled = !self.collectionsList.isEmpty
        self.selectAssetCollectionButton.setTitle(collectionName + (!self.collectionsList.isEmpty ? "  \u{25be}" : "" ), for: .normal)
        self.selectAssetCollectionButton.sizeToFit()
        self.navigationItem.titleView = self.selectAssetCollectionButton
    }
    
    // MARK: - Select group
    
    /**
     Did Click Select Asset Collection Button
     */
    @objc private func didClickSelectAssetCollectionButton() {
        self.showCollectionSelectionViewController()
    }
    
    // MARK: - Navigation
    
    /**
     Show collection selection view controller
     */
    private func showCollectionSelectionViewController() {
        let assetCollectionSelectionView = AssetCollectionSelectionViewController()
        assetCollectionSelectionView.assetsManager = self.assetsManager
        assetCollectionSelectionView.assetCollections = self.collectionsList
        assetCollectionSelectionView.selectedCollection = self.selectedAssetCollection
        assetCollectionSelectionView.selectedGroupDidChangeBlock = { (selectedCollection) in
            self.selectedAssetCollection = selectedCollection
            
            // Update select asset collection button
            self.updateSelectAssetCollectionButton()
            
            // Update view model
            self.loadAssets()
            
            // Reload data
            self.collectionView.reloadData()
        }
        
        assetCollectionSelectionView.modalPresentationStyle = UIModalPresentationStyle.popover
        assetCollectionSelectionView.popoverPresentationController?.sourceView = self.selectAssetCollectionButton
        assetCollectionSelectionView.popoverPresentationController?.sourceRect = self.selectAssetCollectionButton.frame
        assetCollectionSelectionView.popoverPresentationController?.sourceRect.origin.x = 0
        assetCollectionSelectionView.popoverPresentationController?.delegate = self
        
        self.present(assetCollectionSelectionView, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension JNPhotoGalleryViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

// MARK: - UICollectionViewDataSource
extension JNPhotoGalleryViewController: UICollectionViewDataSource {
    
    /**
     Number of sections
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     Number of items in section
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfItem(inSection: section)
    }
    
    /**
     Cell for item at index
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let itemSize = (self.collectionView.collectionViewLayout as? JNPhotoGalleryCollectionViewLayout)?.itemSize ?? CGSize.zero
        
        if let representable = self.viewModel.representableForItem(at: indexPath) as? JNImageCollectionViewCellRepresentable {
            representable.cellSize = itemSize
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: representable.reuseIdentifier, for: indexPath) as? JNImageCollectionViewCell
            cell?.setup(representable: representable)
            
            return cell!
        }
        
        if let representable = self.viewModel.representableForItem(at: indexPath) as? JNCameraCollectionViewCellRepresentable {
            representable.cellSize = itemSize
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: representable.reuseIdentifier, for: indexPath) as? JNCameraCollectionViewCell
            
            return cell!
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension JNPhotoGalleryViewController: UICollectionViewDelegate {
    
    /**
     Should select item at index path
     */
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if self.viewModel.representableForItem(at: indexPath) is JNCameraCollectionViewCellRepresentable {
            return true
        }

        if !self.singleSelect, self.viewModel.selectedAssets.count >= self.maxSelectableCount {
            return false
        }
        
        return true
    }
    
    /**
     Did select item at index path
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let representable = self.viewModel.representableForItem(at: indexPath) as? JNCameraCollectionViewCellRepresentable {
            
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
                self.present(imagePickerViewController, animated: true, completion: nil)
            }
            
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
            return
        }
        
        self.viewModel.selectItem(at: indexPath)
    }
    
    /**
     Did deselect item at index
     */
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.viewModel.deselectItem(at: indexPath)
    }
}

/// JNPhoto Gallery View Controller Delegate
public protocol JNPhotoGalleryViewControllerDelegate: NSObjectProtocol {
    
    /**
     Did select assets
     - Parameter assets: Selected assets array
     */
    func JNPhotoGalleryViewController(didSelectAssets assets: [JNAsset])
    
    /**
     Did Exceed Maximum image size.
     */
    func JNPhotoGalleryViewControllerDidExceedMaximumImageSize()
}


// MARK: - UIImagePickerController, UINavigationControllerDelegate
extension JNPhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     Did finish picking media with info
     */
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
    /**
     Image Picker Controller Did Cancel
     */
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
