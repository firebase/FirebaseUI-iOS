Pod::Spec.new do |s|
  s.name         = "FirebaseUI"
  s.version      = "0.1.0"
  s.summary      = "UI binding libraries for Firebase."
  s.homepage     = "https://github.com/firebase/FirebaseUI-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.source       = { :git => "https://github.com/firebase/FirebaseUI-iOS.git", :tag => 'v0.1.0' }
  s.source_files = "FirebaseUI/**/*.{h,m}"
  s.dependency  'Firebase', '~> 2.2'
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.ios.framework = 'UIKit'
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Firebase"'}
  s.requires_arc = true
end
