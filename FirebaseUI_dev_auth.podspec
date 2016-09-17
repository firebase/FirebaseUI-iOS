Pod::Spec.new do |s|
  s.name         = 'FirebaseAuthUI'
  s.version      = '0.5.6-rc2'
  s.summary      = 'UI Auth Base library for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'AuthBase'

  s.subspec 'AuthBase' do |authbase|
    authbase.source_files = "FirebaseAuthUI/*.{h,m}"
    authbase.resources = "FirebaseAuthUI/{Resources,Strings}/*", "FirebaseAuthUI/*.xib"
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

end
