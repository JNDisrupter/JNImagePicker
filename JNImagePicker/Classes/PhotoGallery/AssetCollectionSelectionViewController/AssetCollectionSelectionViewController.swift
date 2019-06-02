//
//  AssetCollectionSelectionViewController.swift
//  JNImagePicker
//
//  Created by Mohammad Nabulsi on 5/14/19.
//

import UIKit
import Photos

/// Asset CollectionSelectionViewController
class AssetCollectionSelectionViewController: UIViewController {

    /// Table view
    internal var tableView: UITableView!
    
    /// Assets manager
    var assetsManager: JNAssetsManager!
    
    /// Selected collection
    var selectedCollection: PHAssetCollection?
    
    /// Asset Collections
    var assetCollections: [PHAssetCollection]!
    
    /// Selection change callback
    var selectedGroupDidChangeBlock:((_ selectedCollection: PHAssetCollection)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        self.setupTableView()
    }
    
    /// Preferred Content Size
    override var preferredContentSize: CGSize {
        get {
            if let groups = self.assetCollections {
                return CGSize(width: UIScreen.main.bounds.width,
                              height: CGFloat(groups.count) * self.tableView.rowHeight)
            } else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    // MARK: - TableView
    
    /**
     Setup table view
     */
    private func setupTableView() {
        self.tableView = UITableView(frame: CGRect.zero)
        self.tableView.rowHeight = 80
        self.tableView.backgroundColor = UIColor.white
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        // Add collection view constraints
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        // Register cell
        AssetCollectionSelectionTableViewCell.registerCell(tableView: self.tableView)
    }
}

// MARK: - UITableViewDataSource
extension AssetCollectionSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AssetCollectionSelectionTableViewCell.getReuseIdentifier()) as? AssetCollectionSelectionTableViewCell
        let currentCollection = self.assetCollections[indexPath.row]
        cell?.setup(collection: currentCollection, isSelected: currentCollection == selectedCollection, assetManager: self.assetsManager)
        return cell!
    }
}

// MARK: - UITableViewDelegate
extension AssetCollectionSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.selectedCollection = self.assetCollections[indexPath.row]
            self.selectedGroupDidChangeBlock?(self.selectedCollection!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
