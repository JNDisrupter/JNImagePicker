#
# Be sure to run `pod lib lint JNImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                                        = 'JNImagePicker'
  s.version                                     = '0.3.0'
  s.summary                                     = 'JNImagePicker'
  s.description                                 = 'Image picker for images and viewdes'
  s.homepage                                    = 'https://github.com/JNDisrupter'
  s.license                                     = { :type => 'MIT', :file => 'LICENSE' }
  s.author                                      = { 'mohammadnabulsi' => 'mohammad.s.nabulsi@gmail.com' }
  s.source                                      = { :git => 'https://github.com/JNDisrupter/JNImagePicker.git', :tag => s.version.to_s }
  s.ios.deployment_target                       = '11.0'
  s.source_files                                = 'JNImagePicker/Classes/**/*'
  s.resources                                   = 'JNImagePicker/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,ttf}'
  s.swift_version                               = '5.7'
end
