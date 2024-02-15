#
# Be sure to run `pod lib lint ZCRMiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZCRMiOS'
  s.version          = '1.50.2'
                          s.summary          = 'A short description of ZCRMiOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zoho/CRM-iOSSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'boopathypsiva' => 'boopathy.p@zohocorp.com' }
  s.source           = { :git => 'https://github.com/zoho/CRM-iOSSDK.git', :tag => s.version.to_s }
  
  s.vendored_frameworks = 'Example/Pods/ZohoAuth/ZohoAuthKit.framework', 'Example/Pods/ZohoPortalAuth/ZohoPortalAuthKit.framework'

  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ZCRMiOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZCRMiOS' => ['ZCRMiOS/Assets/*.png']
  # }
  
  s.public_header_files = 'Pod/Classes/**/*.h'
  
  s.dependency 'SQLCipher', '~> 4.5.2'
  s.public_header_files = '"${PODS_ROOT}/Pods/Target Support Files/SQLCipher/SQLCipher-umbrella.h"'
  
  s.subspec 'SQLCipher' do |ss|
      ss.dependency 'SQLCipher', '~> 4.5.2'
      ss.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DSQLCipher', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SQLITE_HAS_CODEC=1'}
  end
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

end
