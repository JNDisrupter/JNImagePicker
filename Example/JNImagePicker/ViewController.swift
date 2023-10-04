//
//  ViewController.swift
//  JNImagePicker
//
//  Created by mohammadnabulsi on 05/13/2019.
//  Copyright (c) 2019 mohammadnabulsi. All rights reserved.
//

import UIKit
import JNImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Open JNImage Picker ViewController With Custom Appearance
     */
    @IBAction func openJNImagePickerViewControllerWithCustomAppearance(_ sender: Any) {
        
        // Init
        let imagePickerViewController = JNImagePickerViewController()
        imagePickerViewController.mediaType = .image
        imagePickerViewController.maximumMediaSize = 1
        imagePickerViewController.sourceType = .gallery
        imagePickerViewController.maximumTotalMediaSizes = 5
        imagePickerViewController.pickerDelegate = self
        
        // Setup appearance
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()

            // Configure With Opaque Background
            appearance.configureWithOpaqueBackground()

            // Set Background
            appearance.backgroundColor = UIColor(red: 126.0/255.0, green: 188.0/255.0, blue: 211.0/255.0, alpha: 1.0)

            // Reset Shadow Image
            appearance.shadowImage = nil

            // Set Title Text Attributes
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkGray.cgColor ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0)]

            // Bar Button Item Appearance
            let barButtonItemAppearance = UIBarButtonItemAppearance(style: UIBarButtonItem.Style.plain)
            barButtonItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkGray ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0)]
            appearance.buttonAppearance = barButtonItemAppearance

            // Set Large Title Text Attributes
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkGray.cgColor ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30.0)]

            // Set scroll edge and standard appearance
            imagePickerViewController.navigationBar.scrollEdgeAppearance =  appearance
            imagePickerViewController.navigationBar.standardAppearance = appearance
        } else {
            // Set large Title Text Attributes
            imagePickerViewController.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkGray.cgColor ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30.0)]
            imagePickerViewController.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never
            
            // Setup custom navigation bar
            imagePickerViewController.navigationController?.navigationBar.shadowImage = nil
            imagePickerViewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkGray.cgColor ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0)]
        }
        
        // Setup custom navigation bar
        imagePickerViewController.navigationBar.barStyle = UIBarStyle.default
        imagePickerViewController.navigationBar.isTranslucent = false
        imagePickerViewController.navigationBar.tintColor = UIColor.white
        
        self.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    /**
     Open JNImage Picker ViewController With Defult Appearance
     */
    @IBAction func openJNImagePickerViewControllerWithDefualtAppearance(_ sender: Any) {
        // Init
        let imagePickerViewController = JNImagePickerViewController()
        imagePickerViewController.mediaType = .image
        imagePickerViewController.maximumMediaSize = 10
        imagePickerViewController.sourceType = .gallery
        imagePickerViewController.maximumTotalMediaSizes = 2
        imagePickerViewController.pickerDelegate = self
        imagePickerViewController.maxSelectableCount = 2
        
        self.present(imagePickerViewController, animated: true, completion: nil)
    }
}

extension ViewController: JNImagePickerViewControllerDelegate {
    func imagePickerViewControllerDidCancelPicker() {
        print("cancel")
    }
    
    func imagePickerViewController(pickerController: JNImagePickerViewController, didSelectAssets assets: [JNAsset]) {
        print("didSelectAssets: ", assets)
    }
    
    func imagePickerViewController(pickerController: JNImagePickerViewController, failedToSelectAsset error: Error?) {
        print("failedToSelectAsset: ", error ?? "")
    }
    
    /**
     Did exceed maximum media size for
     - Parameter mediaType: Media Type.
     - Parameter maximumSize: Media MAximum size.
     - Parameter actualMediaSize: Selected media size
     */
    func imagePickerViewController(didExceedMaximumMediaSizeFor mediaType: JNImagePickerViewController.MediaType, with maximumSize: Double, actualMediaSize: Double){
        
        // Init Alert
        let alertController = UIAlertController(title: "Error", message: "The Selection exceed the maximum media size", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel))
        
        // show Alert
        if let presentedViewController = self.presentedViewController {
            presentedViewController.present(alertController, animated: true)
        }
       
    }
    
    /**
     Did exceed maximum total media sizes for
     - Parameter mediaType: Media Type.
     - Parameter maximumTotalSizes: Media Total Maximum size.
     - Parameter actualMediaSizes: Selected media Total size
     - Parameter selectedMediaCount: Selected media Count
     */
    func imagePickerViewController(didExceedMaximumTotalMediaSizesFor mediaType: JNImagePickerViewController.MediaType, with maximumTotalSizes: Double, actualMediaSizes: Double, selectedMediaCount: Int){
        // Init Alert
        let alertController = UIAlertController(title: "Error", message: "The Selection exceed the allowed total maximum media size", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel))
        
        // show Alert
        if let presentedViewController = self.presentedViewController {
            presentedViewController.present(alertController, animated: true)
        }
    }
}
