Pod::Spec.new do |s|
  s.name         = 'FirebaseTwitterAuthUI'
  s.version      = '4.5.1'
  s.summary      = 'Twitter UI binding library for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "https://github.com/firebase/FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Twitter'

  s.subspec 'Twitter' do |twitter|
    twitter.source_files = "FirebaseTwitterAuthUI/*.{h,m}"
    twitter.resource_bundle = {
      'FirebaseTwitterAuthUI' => ['FirebaseTwitterAuthUI/Strings/**/*',
                                  'FirebaseTwitterAuthUI/Resources/**/*',
                                  'FirebaseTwitterAuthUI/**/*.xib']
    }
    twitter.dependency 'FirebaseAuthUI/AuthBase'
    twitter.dependency 'TwitterKit', '~> 3.0'
    twitter.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PROJECT_DIR)/TwitterCore/iOS"' }
  end

end
