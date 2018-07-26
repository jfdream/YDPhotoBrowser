#
# Be sure to run `pod lib lint YDPhotoBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YDPhotoBrowser'
  s.version          = '1.1.7'
  s.summary          = 'A easy to use frameworks for browsering image,include rotation,zoom in and zoom out etc.(support video preview,like wechat)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    A easy to use frameworks for browsering image,rotation,zoom in and zoom out,custom dismiss annimation.
                       DESC

  s.homepage         = 'https://github.com/jfdream/YDPhotoBrowser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jfdream1992@126.com' => 'jfdream' }
  s.source           = { :git => 'https://github.com/jfdream/YDPhotoBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YDPhotoBrowser/Classes/**/*'
  
   s.resource_bundles = {
     'YDPhotoBrowser' => ['YDPhotoBrowser/Assets/YDPhotoBrowser.bundle/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'SDWebImage'
   s.dependency 'Masonry'
   s.dependency 'SVProgressHUD'
   s.dependency 'ZFPlayer'
   s.dependency 'ZFPlayer/ControlView'
   s.dependency 'ZFPlayer/AVPlayer'
end
