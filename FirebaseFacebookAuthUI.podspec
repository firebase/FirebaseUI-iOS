Pod::Spec.new do |s|
  s.name         = 'FirebaseFacebookAuthUI'
  s.version      = '15.1.0'
  s.summary      = 'A Facebook auth provider for FirebaseAuthUI.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.cocoapods_version = '>= 1.8.0'
  s.swift_versions = '5.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }
  s.swift_version = '6.0'

  s.platform = :ios, '13.0'
  s.public_header_files = 'FirebaseFacebookAuthUI/Sources/Public/FirebaseFacebookAuthUI/*.h'
  s.source_files = 'FirebaseFacebookAuthUI/Sources/**/*.{h,m}'
  s.dependency 'FirebaseAuth'
  s.dependency 'FirebaseCore'
  s.dependency 'FirebaseAuthUI', '~> 15.0'
  s.dependency 'FBSDKLoginKit', '>= 17.0', '< 18.0'
  s.dependency 'FBSDKCoreKit_Basics'
  s.resource_bundles = {
    'FirebaseFacebookAuthUI' => ['FirebaseFacebookAuthUI/Sources/{Resources,Strings}/*.{png,lproj}']
  }

end
