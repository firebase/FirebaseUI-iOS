Pod::Spec.new do |s|
  s.name         = 'FirebasePhoneAuthUI'
  s.version      = '4.5.1'
  s.summary      = 'Phone Auth UI binding library for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "https://github.com/firebase/FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Phone'

  s.subspec 'Phone' do |phone|
    phone.source_files = "FirebasePhoneAuthUI/**/*.{h,m}"
    phone.resource_bundle = {
      'FirebasePhoneAuthUI' => ['FirebasePhoneAuthUI/Strings/**/*',
                                'FirebasePhoneAuthUI/Resources/**/*',
                                'FirebasePhoneAuthUI/**/*.xib']
    }
    phone.dependency 'FirebaseAuthUI/AuthBase'
  end
end
