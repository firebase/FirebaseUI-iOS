Pod::Spec.new do |s|
  s.name         = 'FirebaseEmailAuthUI'
  s.version      = '13.0.0'
  s.summary      = 'An email authentication provider for FirebaseAuthUI.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '11.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.cocoapods_version = '>= 1.8.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }
  s.swift_version = '5.3'

  s.public_header_files = 'FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/*.h'
  s.source_files = 'FirebaseEmailAuthUI/Sources/**/*.{h,m}'
  s.dependency 'FirebaseAuth'
  s.dependency 'FirebaseCore'
  s.dependency 'FirebaseAuthUI'
  s.dependency 'GoogleUtilities/UserDefaults'
  s.resource_bundles = {
    'FirebaseEmailAuthUI' => ['FirebaseEmailAuthUI/Sources/Resources/*.{xib,png}']
  }

end
