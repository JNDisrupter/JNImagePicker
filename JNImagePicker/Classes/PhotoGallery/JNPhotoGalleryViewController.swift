//
//  JNPhotoGalleryViewController.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import UIKit
import Photos
import MobileCoreServices
import AVKit

/// JNPhoto Gallery View Controller
class JNPhotoGalleryViewController: UIViewController {
    
    /// Select Asset Collection Button
    public lazy var selectAssetCollectionButton: UIButton = {
        let button = UIButton()
        
        var globalTitleColor: UIColor?
        
        // Setup appearance
        if #available(iOS 13.0, *) {
            globalTitleColor = self.navigationController?.navigationBar.standardAppearance.buttonAppearance.normal.titleTextAttributes[NSAttributedString.Key.foregroundColor] as? UIColor
        }else{
            globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
        }
  
        button.setTitleColor(globalTitleColor ?? UIColor.black, for: .normal)
        
        var globalTitleFont: UIFont?
        
        // Setup appearance
        if #available(iOS 13.0, *) {
            globalTitleFont = self.navigationController?.navigationBar.standardAppearance.buttonAppearance.normal.titleTextAttributes[NSAttributedString.Key.font] as? UIFont
        }else{
            globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.font] as? UIFont
        }
        
        button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(self, action: #selector(self.didClickSelectAssetCollectionButton), for: .touchUpInside)
        return button
    }()
    
    /// Collection view
    internal var collectionView: UICollectionView!
    
    /// Loading view
    internal var loadingView: UIView!
    
    /// Manage limited access view
    internal var manageLimitedAccessView: UIView!
    
    /// Assets manager
    private var assetsManager: JNAssetsManager!
    
    /// Collections list
    private var collectionsList: [PHAssetCollection] = []
    
    /// Selected Asset collection
    private var selectedAssetCollection: PHAssetCollection?
    
    /// View model
    private var viewModel: JNPhotoGalleryViewModel!
    
    /// Maximum Media Size in MB default is -1 if -1 then there is no limit
    public var maximumMediaSize: Double = -1
    
    /// Maximum Total Images Sizes in MB default is -1 if -1 then there is no limit
    public var maximumTotalMediaSizes: Double = -1
    
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
        
    /// Video delivery mode
    public var videoDeliveryMode: PHVideoRequestOptionsDeliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
    
    /// Image delivery mode
    public  var imageDeliveryMode: PHImageRequestOptionsDeliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
    
    /// Delegate
    public weak var delegate: JNPhotoGalleryViewControllerDelegate?
    
    /// Is limited access enabled
    private var isLimitedAccessEnabled: Bool {
        
        var isLimited = false
        
        if #available(iOS 14, *) {
            isLimited = PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
        }
        return isLimited
    }
    
    /// JN Image Picker Localization Configuration
    private var localizationConfiguration: JNImagePickerLocalizationConfiguration {
        // Get Navigation Controller
        if let navigationController = self.navigationController as? JNImagePickerViewController {
             return navigationController.localizationConfiguration
        }
        
        return JNImagePickerLocalizationConfiguration()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.white
        
        // Init assets manager
        self.assetsManager = JNAssetsManager()
        
        // Get collections list
        self.collectionsList = self.assetsManager.getAssetCollections(subTypes: self.assetGroupTypes, options: nil)
        self.selectedAssetCollection = self.collectionsList.first
        
        // Init view model
        self.viewModel = JNPhotoGalleryViewModel(singleSelect: self.singleSelect, maxSelectableCount: self.maxSelectableCount, sourceType: sourceType)
        self.viewModel.setSelectedAssets(self.defaultSelectedAssets ?? [])
        
        // Init loading view
        self.initLoadingView()
        
        // Load assets
        self.loadAssets()
            
        // Check if there is manage limited access string, then init manage limited access view
        if self.isLimitedAccessEnabled  {
            self.initManageLimitedAccessView()
        }
        
        // Init collection view
        self.initCollectionView()
        
        // Update select asset collection button
        self.updateSelectAssetCollectionButton()
        
        // Init navigation item
        self.initNavigationItem()
        
        // Register for PHPhotoLibraryChangeObserver
        PHPhotoLibrary.shared().register(self)
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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = !self.singleSelect
        self.view.addSubview(self.collectionView)
        
        // Add collection view constraints
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            
        // Check if is limited access enabled
        if self.isLimitedAccessEnabled{
            self.collectionView.topAnchor.constraint(equalTo: self.manageLimitedAccessView.bottomAnchor).isActive = true
        }
        else {
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }
        
        // Register cell
        JNImageCollectionViewCell.registerCell(collectionView: self.collectionView)
        JNCameraCollectionViewCell.registerCell(collectionView: self.collectionView)
    }
    
    // MARK: - Manage Limited Access View
    
    /**
     Initialize manage limited access view
     */
    private func initManageLimitedAccessView() {
        
        // Init manage limited access view
        self.manageLimitedAccessView = UIView()
        self.manageLimitedAccessView.backgroundColor = UIColor.white
        self.manageLimitedAccessView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.manageLimitedAccessView)

        // Init description label
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor.darkGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = self.localizationConfiguration.limitedAccessWarningView.title
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.manageLimitedAccessView.addSubview(descriptionLabel)
        
        // Init manage button
        let manageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 28))
        manageButton.setTitleColor(UIColor.black, for: .normal)
        manageButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        manageButton.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        manageButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        manageButton.setTitle(self.localizationConfiguration.limitedAccessWarningView.manageAction, for: .normal)
        
        manageButton.addTarget(self, action: #selector(self.didClickManageButton), for: .touchUpInside)
        manageButton.translatesAutoresizingMaskIntoConstraints = false
        self.manageLimitedAccessView.addSubview(manageButton)

        // Add constraints for manage limited access view
        self.manageLimitedAccessView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.manageLimitedAccessView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        if #available(iOS 11, *) {
            self.manageLimitedAccessView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        else {
            self.manageLimitedAccessView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        
        // Add constraints for description label
        descriptionLabel.leadingAnchor.constraint(equalTo: self.manageLimitedAccessView.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: self.manageLimitedAccessView.topAnchor, constant: 8).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: self.manageLimitedAccessView.bottomAnchor, constant: -8).isActive = true

        // Add constraints for manage button
        manageButton.trailingAnchor.constraint(equalTo: self.manageLimitedAccessView.trailingAnchor, constant: -16).isActive = true
        manageButton.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 8).isActive = true
        manageButton.centerYAnchor.constraint(equalTo: self.manageLimitedAccessView.centerYAnchor).isActive = true
        manageButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        manageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Set corner radius
        manageButton.layer.cornerRadius = manageButton.frame.height/2
        manageButton.clipsToBounds = true
    }
    
    /**
     Did click manage button
     */
    @objc private func didClickManageButton() {
        
        // Create action sheet
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add select more photos action
        actionSheet.addAction(UIAlertAction(title: self.localizationConfiguration.limitedAccessWarningView.openLimitedLibraryPickerAction, style: .default) { _ in
            
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            }
        })
        
        // Add change settings action
        actionSheet.addAction(UIAlertAction(title: self.localizationConfiguration.limitedAccessWarningView.openSettingsAction, style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        // Add cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // Present action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Navigation item
    
    /**
     Init navigation item
     */
    private func initNavigationItem() {

        // Set left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: self.localizationConfiguration.cancelString, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.didClickCancelButton))

        // Setup right bar button item
        self.setupRightBarButtonItem()
    }
    
    /**
     Setup right bar button item
     */
    private func setupRightBarButtonItem() {
        
        let rightBarButtonItem = UIBarButtonItem(title: self.localizationConfiguration.doneString, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.didClickDoneButton))
        let numberOFAssetsNumberButton = UIBarButtonItem(title: "(" + self.viewModel.selectedAssets.count.description + ")", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        if self.viewModel.selectedAssets.isEmpty {
            rightBarButtonItem.isEnabled = false
            numberOFAssetsNumberButton.isEnabled = false
        }
        
        if self.singleSelect {
            self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
        } else {
            self.navigationItem.rightBarButtonItems = [rightBarButtonItem, numberOFAssetsNumberButton]
        }
    }
    
    /**
     Did click cancel button
     */
    @objc private func didClickCancelButton() {
        
        // Call delegate
        self.delegate?.galleryViewControllerDidCancelPicker()
        
        // Close View Controller
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Did click done button
     */
    @objc private func didClickDoneButton() {
        
        /**
         Is media size valid
         - Parameter data: Media data.
         - Returns: Boolean to indicate image data is with valid size
         */
        func isMediaSizeValid(_ data: Data) -> Bool {
            
            // Get maximum media size
            let maximumMediaSize = self.maximumMediaSize > -1 ? self.maximumMediaSize : self.maximumTotalMediaSizes
            
            // Check if image size greater than maximum images sizes
            if maximumMediaSize > -1 && Double(data.count) >= (maximumMediaSize * 1024 * 1024) {
                return false
            }
            
            return true
        }
        
        /**
         Cancel images requests
         - Parameter  imageRequests: Image requests
         */
        func cancelImagesRequests(imageRequests: [PHImageRequestID]) {
            for request in imageRequests {
                PHImageManager.default().cancelImageRequest(request)
            }
        }
        
        // Loading view
        let loadingView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingView.startAnimating()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: loadingView)]
        
        // Selected assets
        var selectedAssets: [JNAsset] = []
        var imagesRequests: [PHImageRequestID] = []
        let assets = self.viewModel.selectedAssets
        var imageSizeExceedLimit = false
        
        // Image options
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = self.imageDeliveryMode
        imageOptions.isNetworkAccessAllowed = true
        
        // Video delivery mode
        let videoOptions = PHVideoRequestOptions()
        videoOptions.deliveryMode = self.videoDeliveryMode
        videoOptions.isNetworkAccessAllowed = true
        
        // Show Loading View
        self.showHideLoadingView(true)
        
        for asset in assets {
            
            if asset.mediaType == PHAssetMediaType.image {
                
                let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: imageOptions) { [weak self] (data, string, imageOrientation, info) in
                    
                    guard let strongSelf = self, let data = data,!imageSizeExceedLimit else {
                        
                        DispatchQueue.main.async {
                            // Setup right bar button item
                            self?.setupRightBarButtonItem()
                            
                            // Hide Loading View
                            self?.showHideLoadingView(false)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // Hide Loading View
                        self?.showHideLoadingView(false)
                        
                        // Check if image size is valid
                        if isMediaSizeValid(data) {
                            selectedAssets.append(JNAsset(originalAsset: asset, assetData: data, assetInfo: info ?? [:], assetExtension: "jpg"))
                        } else {
                            imageSizeExceedLimit = true
                            let limitSize = strongSelf.maximumMediaSize > -1 ? strongSelf.maximumMediaSize : strongSelf.maximumTotalMediaSizes
                            
                            let actualMediaSize = Double(data.count / (1024 * 1024))
                           strongSelf.delegate?.galleryViewController(didExceedMaximumMediaSizeFor: JNImagePickerViewController.MediaType.image, with: limitSize, actualMediaSize: actualMediaSize)
                            
                            // Setup right bar button item
                            strongSelf.setupRightBarButtonItem()
                            
                            cancelImagesRequests(imageRequests: imagesRequests)
                            return
                        }
                        
                        // Check total max image size
                        if selectedAssets.count == assets.count {
                            var totalImagesSize = selectedAssets.reduce(0, { (result, asset) -> Int in
                                result + (asset.assetData?.count ?? 0)
                            })
                            
                            totalImagesSize = totalImagesSize / (1024 * 1024)
                            if strongSelf.maximumTotalMediaSizes > -1 && Double(totalImagesSize) >= strongSelf.maximumTotalMediaSizes {
                               
                                strongSelf.delegate?.galleryViewController(didExceedMaximumTotalMediaSizesFor: strongSelf.mediaType, with: strongSelf.maximumTotalMediaSizes, actualMediaSizes: Double(totalImagesSize), selectedMediaCount:  selectedAssets.count)
                                
                                // Setup right bar button item
                                strongSelf.setupRightBarButtonItem()
                            } else {
                                strongSelf.delegate?.galleryViewController(didSelectAssets: selectedAssets)
                                strongSelf.didClickCancelButton()
                            }
                        }
                    }
                }
                imagesRequests.append(imageRequestID)
            } else {
                
                let imageRequestID = PHImageManager().requestAVAsset(forVideo: asset, options: videoOptions) { [weak self] (avasset, mix, info) in
                    
                    guard let strongSelf = self, let avasset = avasset as? AVURLAsset else {
                        DispatchQueue.main.async {
                            
                            // Hide Loading View
                            self?.showHideLoadingView(false)
                            
                            // Setup right bar button item
                            self?.setupRightBarButtonItem()
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        // Hide Loading View
                        self?.showHideLoadingView(false)
                        
                        let videoData = try? Data(contentsOf: avasset.url)
                        
                        guard let data = videoData else {
                            
                            // Hide Loading View
                              self?.showHideLoadingView(false)

                            // Setup right bar button item
                            self?.setupRightBarButtonItem()
                            return
                        }
                        
                        // Check if image size is valid
                        if isMediaSizeValid(data) {
                            selectedAssets.append(JNAsset(originalAsset: asset, assetData: data, assetInfo: info ?? [:], assetExtension: avasset.url.pathExtension.lowercased()))
                        } else {
                            imageSizeExceedLimit = true
                            let limitSize = strongSelf.maximumMediaSize > -1 ? strongSelf.maximumMediaSize : strongSelf.maximumTotalMediaSizes
                            
                            let actualMediaSize = Double(data.count / (1024 * 1024))
                            strongSelf.delegate?.galleryViewController(didExceedMaximumMediaSizeFor: JNImagePickerViewController.MediaType.video, with: limitSize, actualMediaSize: actualMediaSize)
                            
                            // Setup right bar button item
                            strongSelf.setupRightBarButtonItem()
                            
                            cancelImagesRequests(imageRequests: imagesRequests)
                            return
                        }
                        
                        // Check total max image size
                        if selectedAssets.count == assets.count {
                            var totalImagesSize = selectedAssets.reduce(0, { (result, asset) -> Int in
                                result + (asset.assetData?.count ?? 0)
                            })
                            
                            // Convert to MB
                            totalImagesSize = totalImagesSize / (1024 * 1024)
                            
                            if strongSelf.maximumTotalMediaSizes > -1 && Double(totalImagesSize) >= strongSelf.maximumTotalMediaSizes {
                                strongSelf.delegate?.galleryViewController(didExceedMaximumTotalMediaSizesFor: strongSelf.mediaType, with: strongSelf.maximumTotalMediaSizes, actualMediaSizes: Double(totalImagesSize), selectedMediaCount: selectedAssets.count)
                                
                                // Setup right bar button item
                                strongSelf.setupRightBarButtonItem()
                            } else {
                                strongSelf.delegate?.galleryViewController(didSelectAssets: selectedAssets)
                                strongSelf.didClickCancelButton()
                            }
                        }
                    }
                }
                imagesRequests.append(imageRequestID)
            }
        }
    }
    
    /**
     Update select asset collection button
     */
    private func updateSelectAssetCollectionButton() {
        let collectionName = self.selectedAssetCollection?.localizedTitle ?? ""
        self.selectAssetCollectionButton.isEnabled = !self.collectionsList.isEmpty
        self.selectAssetCollectionButton.setTitle(collectionName + (!self.collectionsList.isEmpty ? " ▾" : "" ), for: .normal)
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
    
    
    // MARK: - Loading view
    
    /**
     Initialize Loading View
     */
    private func initLoadingView() {
        
        // Init View
        self.loadingView = UIView(frame: CGRect.zero)
        self.loadingView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.view.addSubview(self.loadingView)
        self.loadingView.isHidden = true
        
        // Init Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        activityIndicator.tintColor =  UIColor.gray
        activityIndicator.color =  UIColor.gray
        activityIndicator.startAnimating()
        self.loadingView.addSubview(activityIndicator)
        
        // Add loading view constraints
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.loadingView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        // Add Activity Indicator Constraints
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor).isActive = true
    }
    
    /**
     Show/Hide LoadingView
     - Parameter show : Bool value to show or hide loading view.
     */
    func showHideLoadingView(_ show : Bool) {
        self.view.bringSubviewToFront(self.loadingView)
        self.loadingView.isHidden = !show
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
            cell?.setup(representable: representable, indexPath: indexPath)
            cell?.delegate = self
            
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

/// JNPhoto Gallery View Controller Delegate
public protocol JNPhotoGalleryViewControllerDelegate: NSObjectProtocol {
    
    /**
     Did select assets
     - Parameter assets: Selected assets array
     */
    func galleryViewController(didSelectAssets assets: [JNAsset])
    
    /**
     Did exceed maximum media size for
     - Parameter mediaType: Media Type.
     - Parameter maximumSize: Media MAximum size.
     - Parameter actualMediaSize: Selected media size
     */
    func galleryViewController(didExceedMaximumMediaSizeFor mediaType: JNImagePickerViewController.MediaType, with maximumSize: Double, actualMediaSize: Double)
    
    /**
     Did exceed maximum total media sizes for
     - Parameter mediaType: Media Type.
     - Parameter maximumTotalSizes: Media Total Maximum size.
     - Parameter actualMediaSizes: Selected media Total size
     - Parameter selectedMediaCount: Selected media Count
     */
    func galleryViewController(didExceedMaximumTotalMediaSizesFor mediaType: JNImagePickerViewController.MediaType, with maximumTotalSizes: Double, actualMediaSizes: Double, selectedMediaCount: Int)
    
    /**
     Did cancel picker.
     */
    func galleryViewControllerDidCancelPicker()
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
        
        return false
    }
    
    /**
     Did select item at index path
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.viewModel.representableForItem(at: indexPath) as? JNCameraCollectionViewCellRepresentable) != nil {
            
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
    }
}

// MARK: - JNImageCollectionViewCellDelegate
extension JNPhotoGalleryViewController: JNImageCollectionViewCellDelegate {
    
    /**
     Did select cell at index path
     - Parameter indexPath: Cell index path
     */
    func imageCollectionViewCell(didSelectCell indexPath: IndexPath) {
        
        if (self.viewModel.representableForItem(at: indexPath) as? JNCameraCollectionViewCellRepresentable) != nil {
            
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
        
        // Check if single select
        if self.singleSelect {
            let selectedItemIndexPath = self.viewModel.selectedItemsIndexPaths().first
            self.viewModel.selectItem(at: indexPath)
            
            // Reload cell
            if let selectedItemIndexPath = selectedItemIndexPath, let cell = collectionView.cellForItem(at: selectedItemIndexPath) as? JNImageCollectionViewCell {
                if let representable = self.viewModel.representableForItem(at: selectedItemIndexPath) as? JNImageCollectionViewCellRepresentable {
                    cell.setup(representable: representable, indexPath: selectedItemIndexPath)
                }
            }
        }
        
        // If multi selection, check if the item is selected, if so deselect it
        else if self.viewModel.isItemSelected(at: indexPath) {
            self.viewModel.deselectItem(at: indexPath)
        }
        
        // Skip if the selected assets is greater or equal to the maximum selectable items
        else if self.viewModel.selectedAssets.count >= self.maxSelectableCount {
            return
        }
        else {
            
            // Select item
            self.viewModel.selectItem(at: indexPath)
        }
        
        // Reload cell
        if let cell = collectionView.cellForItem(at: indexPath) as? JNImageCollectionViewCell {
            if let representable = self.viewModel.representableForItem(at: indexPath) as? JNImageCollectionViewCellRepresentable {
                cell.setup(representable: representable, indexPath: indexPath)
            }
        }
        
        // Setup right bar button item
        self.setupRightBarButtonItem()
    }
}

// MARK: - UIImagePickerController, UINavigationControllerDelegate
extension JNPhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     Did finish picking media with info
     */
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == kUTTypeImage as String {
                var image: UIImage?
                
                if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    image = editedImage
                } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    image = originalImage
                }
                
                if let image = image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            } else {
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path) {
                        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Image Picker Controller Did Cancel
     */
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Did finish saving media
     */
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            return
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension JNPhotoGalleryViewController : PHPhotoLibraryChangeObserver {
    
    /**
     Photo library did change
     */
     func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Media type
        let mediaType: PHAssetMediaType = self.mediaType == .video ? .video : .image
        
        // Set new assets
        self.viewModel.setAssets(self.assetsManager.getAssets(in: self.selectedAssetCollection!, type: mediaType))
        
        // Reload collection view
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
     }
}
