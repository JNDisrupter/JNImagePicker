//
//  JNImageCollectionViewCell.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/13/19.
//

import UIKit
import Photos

/// JNImage Collection View Cell
class JNImageCollectionViewCell: UICollectionViewCell {
    
    /// Image view
    @IBOutlet private weak var imageView: UIImageView!
    
    /// SelectedContainerView
    @IBOutlet private weak var selectedContainerView: UIView!
    
    /// Duration Label
    @IBOutlet private weak var durationLabel: UILabel!
    
    /// Is Selected
    override var isSelected: Bool {
        didSet {
            self.selectedContainerView.isHidden = !self.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    /**
     Setup cell with representable
     */
    func setup(representable: JNImageCollectionViewCellRepresentable) {
        self.isSelected = representable.isSelected
        self.selectedContainerView.isHidden = !representable.isSelected
        self.imageView.setImage(asset: representable.asset!, size: representable.cellSize)
        
        if representable.asset?.mediaType == PHAssetMediaType.video {
            let ti = NSInteger(representable.asset?.duration ?? 0)
            
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)
            
            if hours > 0 {
                self.durationLabel.text = String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
            } else {
                self.durationLabel.text = String(format: "%0.2d:%0.2d",minutes,seconds)
            }
        } else {
            self.durationLabel.text = ""
        }
    }
    
    // MARK: - Class methods
    
    /**
     Get reuse identifier
     - Returns: Reuse identifier.
     */
    class func getReuseIdentifier() -> String {
        return "JNImageCollectionViewCell"
    }
    
    /**
     Register cell
     - Parameter collectionView: The UICollectionView to register cells in it.
     */
    class func registerCell(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "JNImageCollectionViewCell", bundle: Bundle.init(for: JNImageCollectionViewCell.self)), forCellWithReuseIdentifier: self.getReuseIdentifier())
    }
}

extension UIImageView {
    
    /**
     Set image from asset
     - Parameter asset: PHAsset
     - Parameter size: Image size
     */
    func setImage(asset: PHAsset, size: CGSize) {
        self.showLoadingIndicator()
        self.accessibilityLabel = asset.localIdentifier
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { [weak self] (image, options) in
            
            guard let strongSelf = self else { return }
            
            // Check if asset matches asset
            if strongSelf.accessibilityLabel == asset.localIdentifier {
            
                // Set image
                strongSelf.image = image
            
                // Hide loading indicator
                strongSelf.hideLoadingIndicator()
            }
        }
    }
    
    /**
     Show loading indicator
     */
    func showLoadingIndicator() {
        self.hideLoadingIndicator()
        
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.startAnimating()
        loadingIndicator.tag = 404
        self.addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    /**
     Hide loading indicator
     */
    func hideLoadingIndicator() {
        self.viewWithTag(404)?.removeFromSuperview()
    }
}
