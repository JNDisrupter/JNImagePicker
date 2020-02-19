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

    @IBAction func dids(_ sender: Any) {
        let vc = JNImagePickerViewController()
        vc.mediaType = .image
        vc.maximumImageSize = 1
        vc.sourceType = .gallery
        vc.maximumTotalImagesSizes = 5
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: JNImagePickerViewControllerDelegate {
    func imagePickerViewControllerDidCancelPicker() {
        print("cancel")
    }
    
    func imagePickerViewController(pickerController: JNImagePickerViewController, didSelectAssets assets: [JNAsset]) {
        print("ssss", assets)
    }
    
    func imagePickerViewController(pickerController: JNImagePickerViewController, failedToSelectAsset error: Error?) {
        print("ssss", error)
    }
    
    func imagePickerViewController(didExceedMaximumImageSize pickerController: JNImagePickerViewController) {
        print("exceed")
    }
}
