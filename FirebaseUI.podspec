Pod::Spec.new do |s|
  s.name         = "FirebaseUI"
  s.version      = "0.2.6"
  s.summary      = "UI binding libraries for Firebase."
  s.homepage     = "https://github.com/firebase/FirebaseUI-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.social_media_url = "https://twitter.com/firebase"
  s.source       = { :git => "https://github.com/firebase/FirebaseUI-iOS.git", :tag => v0.2.6 }
  s.source_files = "FirebaseUI/**/*.{h,m}"
  s.dependency  "Firebase", "~> 2.4.1.1"
  s.platform = :ios
  s.ios.deployment_target = "8.0"
  s.ios.framework = "UIKit"
  s.requires_arc = true
end
