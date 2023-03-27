Pod::Spec.new do |s|
  s.name         = 'FirebaseDatabaseUI'
  s.version      = '13.0.0'
  s.summary      = 'Prebuilt data sources and UI bindings for Firebase Database.'
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

  s.public_header_files = 'FirebaseDatabaseUI/Sources/Public/FirebaseDatabaseUI/*.h'
  s.source_files = 'FirebaseDatabaseUI/Sources/**/*.{h,m}'
  s.dependency 'FirebaseDatabase', '>= 8.0', '< 11.0'

end
