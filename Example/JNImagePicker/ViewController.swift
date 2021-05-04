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

    @IBAction func openJNImagePickerViewController(_ sender: Any) {
        let vc = JNImagePickerViewController()
        vc.mediaType = .image
        vc.maximumMediaSize = 1
        vc.sourceType = .gallery
        vc.maximumTotalMediaSizes = 5
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
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
         print("exceed")
    }
    
    /**
     Did exceed maximum total media sizes for
     - Parameter mediaType: Media Type.
     - Parameter maximumTotalSizes: Media Total Maximum size.
     - Parameter actualMediaSizes: Selected media Total size
     - Parameter selectedMediaCount: Selected media Count
     */
    func imagePickerViewController(didExceedMaximumTotalMediaSizesFor mediaType: JNImagePickerViewController.MediaType, with maximumTotalSizes: Double, actualMediaSizes: Double, selectedMediaCount: Int){
         print("exceed")
    }
}
