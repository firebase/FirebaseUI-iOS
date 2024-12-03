Pod::Spec.new do |s|
  s.name         = 'FirebaseAuthUI'
  s.version      = '15.0.0'
  s.summary      = 'A prebuilt authentication UI flow for Firebase Auth.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.cocoapods_version = '>= 1.8.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }
  s.swift_version = '6.0'

  s.public_header_files = 'FirebaseAuthUI/Sources/Public/FirebaseAuthUI/*.h'
  s.source_files = 'FirebaseAuthUI/Sources/**/*.{h,m}'
  s.dependency 'FirebaseAuth', '>= 11.0', '< 12.0'
  s.dependency 'FirebaseCore'
  s.resource_bundles = {
    'FirebaseAuthUI' => ['FirebaseAuthUI/Sources/{Resources,Strings}/*.{xib,png,lproj}']
  }

end
