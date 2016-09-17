Pod::Spec.new do |s|
  s.name         = 'FirebaseFacebookAuthUI'
  s.version      = '0.5.6-rc2'
  s.summary      = 'Facebook UI binding library for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Facebook'

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = "FirebaseFacebookAuthUI/*.{h,m}"
    facebook.resources = "FirebaseFacebookAuthUI/{Resources,Strings}/*", "FirebaseFacebookAuthUI/*.xib"
    facebook.dependency 'FirebaseAuthUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

end
