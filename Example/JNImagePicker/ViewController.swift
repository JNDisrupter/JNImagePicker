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
    
        let vc = JNImagePickerViewController()
        vc.mediaType = .all
        vc.maximumImageSize = 1
        vc.sourceType = .both
        vc.maximumTotalImagesSizes = 5
        vc.maxSelectableCount = 1
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

