Pod::Spec.new do |s|
  s.name         = "FirebaseUI"
  s.version      = "0.3.1"
  s.summary      = "UI binding libraries for Firebase."
  s.homepage     = "https://github.com/firebase/FirebaseUI-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.social_media_url = "https://twitter.com/firebase"
  s.source       = { :git => "https://github.com/firebase/FirebaseUI-iOS.git", :tag => 'v0.3.1' }
  s.source_files = "FirebaseUI/**/*.{h,m}"
  s.resources = "FirebaseUI/**/Resources/*"
  s.dependency "Firebase", "~>2.2"
  s.dependency "FBSDKCoreKit"
  s.dependency "FBSDKLoginKit"
  s.dependency "Google/SignIn"
  s.platform = :ios
  s.ios.deployment_target = "8.0"
  s.ios.framework = "UIKit", "Accounts"
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Firebase"' }
  s.requires_arc = true
end
