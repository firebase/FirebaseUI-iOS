Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '1.0.0'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { 'Firebase' => 'support@firebase.com' }
  s.source       = {
    :git => 'https://github.com/firebase/FirebaseUI-iOS.git',
    :tag => "v#{s.version}"}
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Database'

  s.subspec 'Database' do |database|
    database.source_files = "FirebaseUI/{Database,Util}/**/*.{h,m}"
    database.dependency 'Firebase/Database', '~> 3.0'
	database.ios.framework = 'FirebaseDatabase'
	database.xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/FirebaseDatabase/Frameworks"' }
	
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseUI/Facebook'
    auth.dependency 'FirebaseUI/Google'
  end

  s.subspec 'AuthBase' do |authui|
    authui.source_files = "FirebaseUI/Auth/AuthUI/*.{h,m}"
    authui.resources = "FirebaseUI/Auth/AuthUI/{Resources,Strings}/*", "FirebaseUI/Auth/AuthUI/Source/*.xib"
    authui.dependency 'Firebase/Analytics', '~> 3.0'
    authui.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = "FirebaseUI/Auth/AuthProviderUI/Facebook/Source/*.{h,m}"
    facebook.resources = "FirebaseUI/Auth/AuthProviderUI/Facebook/{Resources,Strings}/*", "FirebaseUI/Auth/AuthProviderUI/Facebook/Source/*.xib"
    facebook.dependency 'Firebase/Auth', '~> 3.0'
    facebook.dependency 'FirebaseUI/AuthUI'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.source_files = "FirebaseUI/Auth/AuthProviderUI/Google/Source/*.{h,m}"
    google.resources = "FirebaseUI/Auth/AuthProviderUI/Google/{Resources,Strings}/*", "FirebaseUI/Auth/AuthProviderUI/Google/Source/*.xib"
    google.dependency 'Firebase/Auth', '~> 3.0'
    google.dependency 'FirebaseUI/AuthUI'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end
end
