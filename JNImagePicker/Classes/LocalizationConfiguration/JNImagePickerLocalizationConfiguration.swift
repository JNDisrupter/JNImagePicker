//
//  JNImagePickerLocalizationConfiguration.swift
//  JNImagePicker
//
//  Created by Jayel Zaghmoutt on 4/29/21.
//

import Foundation

/// JN Image Picker Localization Configuration
public struct JNImagePickerLocalizationConfiguration {
    
    /// Cancel
    public var cancelString: String

    /// Done
    public var doneString: String
    
    /// Photo Permission Denied View
    public var photoPermissionDeniedView: PermissionDeniedView
    
    /// Camera Permission Denied View
    public var cameraPermissionDeniedView: PermissionDeniedView
    
    /// Limited Access Warning View
    public var limitedAccessWarningView: LimitedAccessWarningView
        
    /**
     Initializer
     */
    public init() {
        self.cancelString = "Cancel"
        self.doneString = "Done"
        self.photoPermissionDeniedView = PermissionDeniedView()
        self.cameraPermissionDeniedView = PermissionDeniedView()
        self.limitedAccessWarningView = LimitedAccessWarningView()
        
        // Setup Photo Permission Denied View
        self.setupPhotoPermissionDeniedView()
        
        // Setup Camera Permission Denied View
        self.setupCameraPermissionDeniedView()
    }
    
    /**
     Setup Photo Permission Denied View
     */
    private mutating func setupPhotoPermissionDeniedView() {
        
        // App Name
        var appName = ""
        
        // Set App Name
        if let name = Bundle.main.infoDictionary!["CFBundleName"] as? String {
            appName = name
        }
        
        self.photoPermissionDeniedView.title = String(format: "%@ does not have access to your Photos.", appName)
        self.photoPermissionDeniedView.message = "To enable access, tap Settings and enable Photos"
    }
    
    /**
     Setup Camera Permission Denied View
     */
    private mutating func setupCameraPermissionDeniedView() {
        
        // App Name
        var appName = ""
        
        // Set App Name
        if let name = Bundle.main.infoDictionary!["CFBundleName"] as? String {
            appName = name
        }
        
        self.cameraPermissionDeniedView.title = String(format: "%@ does not have access to your Camera.", appName)
        self.cameraPermissionDeniedView.message = "To enable access, tap Settings and enable Camera"
    }
}

/// JN Image Picker Localization Configuration
extension JNImagePickerLocalizationConfiguration {
    
    /// Permission Denied View
    public struct PermissionDeniedView {
        
        /// Title
        public var title: String
        
        /// Message
        public var message: String
        
        /// Open Settings Action
        public var openSettingsAction: String
        
        /// Cancel Action
        public var cancelAction: String
        
        /**
         Initializer
         */
        public init() {
            self.title = ""
            self.message = ""
            self.openSettingsAction = "Change Settings"
            self.cancelAction = "Not Now"
        }
    }
    
    ///  Limited Access Warning View
    public struct LimitedAccessWarningView {
        
        /// Title
        public var title: String
        
        /// Manage Action
        public var manageAction: String
        
        /// Open Limited Library Picker Action
        public var openLimitedLibraryPickerAction: String
        
        /// Open Settings Action
        public var openSettingsAction: String
        
        /**
         Initializer
         */
        public init() {
            
            // App Name
            var appName = ""
            
            // Set App Name
            if let name = Bundle.main.infoDictionary!["CFBundleName"] as? String {
                appName = name
            }
            
            self.title =  String(format: "You have given %@ access to only a select number of photos.", appName)
            self.manageAction = "Manage"
            self.openLimitedLibraryPickerAction = "Select More Photos"
            self.openSettingsAction = "Change Settings"
        }
    }
}
