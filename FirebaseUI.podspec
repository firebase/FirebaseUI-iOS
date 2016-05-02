Pod::Spec.new do |s|
  s.name         = "FirebaseUI"
  s.version      = "1.0.0"
  s.summary      = "UI binding libraries for Firebase."
  s.homepage     = "https://github.com/firebase/FirebaseUI-iOS"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.social_media_url = "https://twitter.com/firebase"
  s.source       = { :git => "https://dev-partners.googlesource.com/firebaseui-ios.git", :tag => "v#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = "7.0"
  s.dependency "Firebase/Database"
  s.ios.framework = "UIKit"
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/FirebaseAnalytics/Frameworks", "${PODS_ROOT}/FirebaseDatabase/Frameworks"' }
  s.requires_arc = true
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = "FirebaseUI/{Core,Util}/**/*.{h,m}"
  end
end
