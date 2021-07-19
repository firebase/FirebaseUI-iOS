Pod::Spec.new do |s|
  s.name         = 'FirebaseOAuthUI'
  s.version      = '11.1.3'
  s.summary      = 'A collection of OAuth providers for FirebaseAuthUI.'
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

  s.public_header_files = 'FirebaseOAuthUI/Sources/Public/FirebaseOAuthUI/*.h'
  s.source_files = 'FirebaseOAuthUI/Sources/**/*.{h,m}'
  s.dependency 'FirebaseAuthUI'
  s.dependency 'FirebaseAuth', '~> 8.0'
  s.resource_bundles = {
    'FirebaseOAuthUI' => ['FirebaseOAuthUI/Sources/{Resources,Strings}/*.{png,lproj}']
  }

end
