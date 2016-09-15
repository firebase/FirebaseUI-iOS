Pod::Spec.new do |s|
  s.name         = 'FirebaseTwitterAuthUI'
  s.version      = '0.5.5'
  s.summary      = 'Twitter UI binding library for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Twitter'

  s.subspec 'Twitter' do |twitter|
    twitter.source_files = "FirebaseTwitterAuthUI/*.{h,m}"
    twitter.resources = "FirebaseTwitterAuthUI/{Resources,Strings}/*", "FirebaseTwitterAuthUI/*.xib"
    twitter.dependency 'FirebaseAuthUI/AuthBase'
    twitter.dependency 'TwitterKit', '~> 2.4'
    twitter.pod_target_xcconfig = { 'CLANG_ENABLE_MODULES' => 'NO' }
  end

end
