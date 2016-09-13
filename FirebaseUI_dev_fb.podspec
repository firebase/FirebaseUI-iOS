Pod::Spec.new do |s|
  s.name         = 'FirebaseUI-fb'
  s.version      = '0.5.4'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Facebook'

  s.subspec 'AuthBase' do |authbase|
    authbase.source_files = "FirebaseAuthUI/*.{h,m}"
    authbase.resources = "FirebaseAuthUI/{Resources,Strings}/*", "FirebaseAuthUI/*.xib"
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = "FirebaseFacebookAuthUI/*.{h,m}"
    facebook.resources = "FirebaseFacebookAuthUI/{Resources,Strings}/*", "FirebaseFacebookAuthUI/*.xib"
    facebook.dependency 'FirebaseUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

end
