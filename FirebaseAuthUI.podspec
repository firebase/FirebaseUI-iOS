Pod::Spec.new do |s|
  s.name         = 'FirebaseAuthUI'
  s.version      = '11.0.0'
  s.summary      = 'A prebuilt authentication UI flow for Firebase Auth.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.cocoapods_version = '>= 1.8.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }

  s.public_header_files = 'FirebaseAuthUI/Sources/Public/FirebaseAuthUI/*.h'
  s.source_files = 'FirebaseAuthUI/Sources/**/*.{h,m}'
  s.dependency 'Firebase/Auth', '~> 7.2.0'
  s.dependency 'FirebaseAuth'
  s.dependency 'FirebaseCore'
  s.dependency 'GoogleUtilities/UserDefaults'
  s.resource_bundle = {
    'FirebaseAuthUI' => ['FirebaseAuthUI/Sources/{Resources,Strings}/*.{xib,png,lproj}']
  }

end
