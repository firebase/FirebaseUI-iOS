Pod::Spec.new do |s|
  s.name         = 'FirebaseStorageUI'
  s.version      = '11.0.0'
  s.summary      = 'UI binding libraries for Firebase.'
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

  # s.tvos.deployment_target = '11.0' Disabled; one of the dependencies doesn't support tvOS.
  s.public_header_files = 'FirebaseStorageUI/Sources/Public/*.h'
  s.source_files = 'FirebaseStorageUI/Sources/**/*.{h,m}'
  s.dependency 'Firebase/Storage'
  s.dependency 'GTMSessionFetcher/Core', '~> 1.5.0'
  s.dependency 'SDWebImage', '~> 5.6'

end
