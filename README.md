# JNImagePicker

[![CI Status](https://img.shields.io/travis/mohammadnabulsi/JNImagePicker.svg?style=flat)](https://travis-ci.org/mohammadnabulsi/JNImagePicker)
[![Version](https://img.shields.io/cocoapods/v/JNImagePicker.svg?style=flat)](https://cocoapods.org/pods/JNImagePicker)
[![License](https://img.shields.io/cocoapods/l/JNImagePicker.svg?style=flat)](https://cocoapods.org/pods/JNImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/JNImagePicker.svg?style=flat)](https://cocoapods.org/pods/JNImagePicker)

## Preview
<img src="https://github.com/JNDisrupter/JNImagePicker/blob/update-readmeFile/Images/recentContent.png" width="280"/> <img src="https://github.com/JNDisrupter/JNImagePicker/blob/update-readmeFile/Images/favoriteContent.png" width="280"/> <img src="https://github.com/JNDisrupter/JNImagePicker/blob/update-readmeFile/Images/albumsSwitcher.png" width="280"/> <img src="https://github.com/JNDisrupter/JNImagePicker/blob/update-readmeFile/Images/selections.png" width="280"/>

## Requirements

- Xcode 9
- iOS 9.0+
- Swift 4.2+

## Installation

JNImagePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JNImagePicker'
```
## Usage

- Import **JNImagePicker module**
```swift
import JNImagePicker
```
- **Initalization:**

Initialize the image picker object

```swift
let imagePickerViewController() = JNImagePickerViewController()
```

- **Setup:**

you can setup multiple parameters as shown below, for example:
```swift
vc.mediaType = .image
vc.maximumMediaSize = 1
vc.sourceType = .gallery
vc.maximumTotalMediaSizes = 5
vc.pickerDelegate = self
```

Then display the view by calling
```swift
self.present(imagePickerViewController, animated: true, completion: nil)
```

  - **Parameters:**
    - ***mediaType:***
  This is for choosing the needed media type to be picked, you can choose between **image, video, all**
    - ***maximumMediaSize:***
  This is for deciding the maximum media size to be select in MB per each item, by default its value is **-1** which means no limit
    - ***sourceType:***
  This is for choosing the source of media to be selected from, you can choose between **camera, gallery, both**
    - ***maximumTotalMediaSizes:***
  This is for deciding the maximum media size to be select in MB for all selected items in total, by default its value is **-1** which means no limit
    - ***singleSelect:***
  A boolean flag to decide if you want to enable the user to select multiple images or just one item, be default its value is **false** which means multiple selection enabled
    - ***maxSelectableCount:***
  This is to decide the maximum items count allowed to be selected from the picker, by default its value is **999**
    - ***allowEditing:***
    This is for allowing the user to edit the selected image by croping it for example, by default its value is **false**, so initially the editing is disabled
    - ***pickerDelegate:***
  A delegate that informs the listener with some needed informations, you can check them below

- **Delegates:**
  - **JNImagePickerViewControllerDelegate:**
  You need this delegate to monitor some information like the media size exceeded, and to get the list of selected media
    - ***didSelectAssets:***
    This returns a list of selected assets
    - ***failedToSelectAsset:***
    This returns an error to indicate that a problem happened when selected an asset
    - ***didExceedMaximumMediaSize:***
    This is to indicate that the selected media size is greater than the maximum
    - ***didExceedMaximumTotalMediaSizesFor:***
    This is to indicate that the total size of the selected media is greater than the maximum
    - ***imagePickerViewControllerDidCancelPicker:***
    This is to inform the view that the user clicked on **cancel** button
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Jayel Zaghmoutt, mohammad.s.nabulsi@gmail.com

## License

JNImagePicker is available under the MIT license. See the LICENSE file for more info.
