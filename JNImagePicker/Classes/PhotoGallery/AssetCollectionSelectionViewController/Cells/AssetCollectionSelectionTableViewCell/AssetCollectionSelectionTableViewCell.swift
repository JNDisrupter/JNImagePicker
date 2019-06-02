//
//  AssetCollectionSelectionTableViewCell.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/14/19.
//

import UIKit
import Photos

/// Asset Collection Selection Table View Cell
class AssetCollectionSelectionTableViewCell: UITableViewCell {

    /// Collection image
    @IBOutlet private weak var collectionImage: UIImageView!
    
    /// Title label
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set selection style
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }

    /**
     Setup cell for collection
     - Parameter collection: PHAsset collection
     - Parameter isSelected: Flag to indicate if selected.
     - Parameter assetManager: Asset Manager.
     */
    func setup(collection: PHAssetCollection, isSelected: Bool, assetManager: JNAssetsManager) {
        self.titleLabel.text = collection.localizedTitle
        self.accessoryType = isSelected ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        
        assetManager.getAssetCollectionThumbnail(collection: collection, size: CGSize(width: 100, height: 100)) { (image) in
            self.collectionImage.image = image
        }
    }
    
    // MARK: - Class methods
    
    /**
     Get reuse identifier
     - Returns: Reuse identifier.
     */
    class func getReuseIdentifier() -> String {
        return "AssetCollectionSelectionTableViewCell"
    }
    
    /**
     Register cell
     - Parameter tableView: The UITableView to register cells in it.
     */
    class func registerCell(tableView: UITableView) {
        tableView.register(UINib(nibName: "AssetCollectionSelectionTableViewCell", bundle: Bundle.init(for: AssetCollectionSelectionTableViewCell.self)), forCellReuseIdentifier: self.getReuseIdentifier())
    }
}
